module Main (main) where

-- this file really needs cleaning up and things moved out of it

import Gauges.CLI.Credentials (credentialPath,
                               readCredential,
                               validateCredential,
                               writeCredential)
import Gauges.CLI.Interact (sayLine, saysLine, say, ask, prompt)
import Gauges.CLI.Display (Displayable(..), displayResult)
import Gauges.CLI.Spark (Sparkable(sparkResult))
import Gauges.CLI.Help (help, interactiveHelp, unknownCmd)
import Gauges.CLI.GaugeCache (writeGaugeCache, readGaugeId)
import Gauges.API.Client (Client, createClient, getResponse)  
import Gauges.API.Resources (ResourceId, gaugesR, gaugeTrafficR)
import Gauges.API.Data (GaugesSummary(summary), GaugeSummary(title,gaugeId), GaugeTraffic(total,history))
import System.Directory (doesFileExist)
import System (getArgs)
import System.Locale (defaultTimeLocale)
import Data.Time.Clock (getCurrentTime)
import Data.Time.Format (formatTime)
import Data.List (intercalate)
import Network.Curl.Code (CurlCode(..))
import Text.JSON (Result(..), decode)

main = do
  args <- getArgs
  case args of 
    ["--help"]  -> sayLine help
    ["-h"]      -> sayLine help
    ["help"]    -> sayLine help
    []          -> startInteractive
    command     -> startAuthorized command
    
runAuthorized :: Client -> [String] -> String -> IO ()
runAuthorized cl command help = do
  case command of 
    ["list"]             -> listCommand cl
    "traffic":name:opts  -> trafficCommand cl name opts
    _                    -> sayLine help
    
runInteractive :: Client -> IO ()
runInteractive cl = do
  command <- prompt  
  case command of
    ["quit"] -> endInteractive
    ["q"]    -> endInteractive
    ["help"] -> (say interactiveHelp) >> runInteractive cl 
    []       -> runInteractive cl
    _        -> runAuthorized cl command unknownCmd >> runInteractive cl    
  
startAuthorized :: [String] -> IO ()  
startAuthorized command = do                   
  cl <- readClient
  runAuthorized cl command help

startInteractive :: IO ()
startInteractive = do
  client <- readClient
  sayLine "Welcome to Gauges Haskell CLI"
  sayLine "type \"help\" and press ENTER to see what's up"
  runInteractive client                  
  
endInteractive :: IO ()  
endInteractive = sayLine "Godbye!"      
  
-- this is just getting bad now                 
listCommand :: Client -> IO ()  
listCommand c = do  
  (res,resp) <- getResponse c gaugesR
  case res of 
    CurlOK ->  (cacheAndReturn (decoded resp)) >>= \t -> say (displayResult t) -- displayResult (decode resp :: Result GaugesSummary)
    _      ->  say "Failed to download information about gauges."
    where 
      decoded :: String -> Result GaugesSummary
      decoded s = decode s :: Result GaugesSummary
      cacheData (Ok gs) = map (\t -> (title t, gaugeId t)) (summary gs)
      cacheData (Error _) = []
      cacheAndReturn :: Result GaugesSummary -> IO (Result GaugesSummary)
      cacheAndReturn res  = do
        writeGaugeCache $ cacheData res
        return res
        
trafficCommand :: Client -> String -> [String] -> IO ()
trafficCommand cl gaugeName opts = do
  mbGaugeId <- readGaugeId gaugeName
  maybe (gaugeNotFound gaugeName) (showTraffic cl opts) mbGaugeId
  
showTraffic :: Client -> [String] -> ResourceId -> IO ()  
showTraffic cl opts gaugeId = do
  date <- getMonthBasedDate opts
  (res,resp) <- getResponse cl $ gaugeTrafficR gaugeId date
  case res of 
    CurlOK -> printFun opts $ decoded resp
    _      -> say "failed to download traffic for gauge"
    where
      decoded s = decode s :: Result GaugeTraffic  
      printFun :: [String] -> Result GaugeTraffic -> IO ()
      printFun opts = if any (=="--spark") opts
                      then sparkResult
                      else say . displayResult
      
  
gaugeNotFound :: String -> IO ()
gaugeNotFound name = do
  putStrLn $ "could not find gauge: " ++ name
  putStrLn "Either the gauge does not exist or the gauge cache needs to be refreshed. Run \"list\" and try again."
        
-- this is pretty disgusting me thinks?
readClient :: IO Client 
readClient = do
  credsPath <- credentialPath
  hasCreds <- doesFileExist credsPath              
  if hasCreds
    then (saysLine ["Using credential from", credsPath]) >> readCredential credsPath
    else newAndValidate
    where
      newAndValidate :: IO Client
      newAndValidate = newClient >>= validateCredential >>= \mbC -> case mbC of 
        Just cl -> writeCredential cl >> return cl
        Nothing -> (say "invalid API Key") >>  newAndValidate
            
         
newClient :: IO String
newClient = do
  ask "You have not setup an API Key. Please enter one: "         
         
getMonthBasedDate :: [String] -> IO String    
getMonthBasedDate opts = do
  buildMonthBasedDate (mbMonth opts) (mbYear opts)
  where
    -- todo: this can be cleaned up/abstracted
    mbMonth opts = case break hasMonthSwitch opts of
      (_, _:month:_) -> Just month
      _              -> Nothing
    mbYear opts  = case break hasYearSwitch opts of
      (_, _:year:_) -> Just year
      _             -> Nothing
    hasYearSwitch s  = s == "--year" || s == "-y"
    hasMonthSwitch s = s == "--month" || s == "-m"
    
buildMonthBasedDate :: Maybe String -> Maybe String -> IO String     
buildMonthBasedDate mbMonth mbYear = do
  now <- getCurrentTime
  return $ intercalate "-" [(year (defaultYear now) mbYear), (month (defaultMonth now) mbMonth), "01"] 
  where  
    year def mbY      = maybe def (prepedYear def) mbY
    month def mbM     = maybe def (prepedMonth def) mbM
    prepedYear def y  = if validYear y 
                        then buildYear y
                        else def
    prepedMonth def m = if validMonth m                        
                        then buildMonth m
                        else def
    defaultYear now   = formatTime defaultTimeLocale "%Y" now
    defaultMonth now  = formatTime defaultTimeLocale "%m" now
    
validYear :: String -> Bool
validYear yearStr = (length yearStr == 2 || length yearStr == 4) && onlyNumbers yearStr

buildYear :: String -> String
buildYear yearStr
  | (length yearStr) == 2 = "20" ++ yearStr
  | otherwise             = yearStr
                            
validMonth :: String -> Bool                            
validMonth monthStr = (length monthStr == 1 || length monthStr == 2) && onlyNumbers monthStr

buildMonth :: String -> String
buildMonth monthStr 
  | strLength == 1                          = '0':monthStr
  | strLength == 2 && (head monthStr > '1') = '0':(tail monthStr) -- nasty adjustment for human error
  | otherwise                               = monthStr
  where 
    strLength = length monthStr
    
onlyNumbers :: String -> Bool
onlyNumbers s = (all (>='0') s) && (all (<='9') s)
                      
    
