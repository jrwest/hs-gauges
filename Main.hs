module Main (main) where

-- this file really needs cleaning up and things moved out of it

import Gauges.CLI.Credentials (credentialPath,
                               readCredential,
                               validateCredential,
                               writeCredential)
import Gauges.CLI.Interact (sayLine, saysLine, say, ask, prompt)
import Gauges.CLI.Display (Displayable(..), displayResult)
import Gauges.CLI.Help (help, interactiveHelp, unknownCmd)
import Gauges.CLI.GaugeCache (writeGaugeCache)
import Gauges.API.Client (Client, createClient, getResponse)  
import Gauges.API.Resources (gaugesR)
import Gauges.API.Data (GaugesSummary(summary), GaugeSummary(title,gaugeId))
import System.Directory (doesFileExist)
import System (getArgs)
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
    ["list"] -> listCommand cl
    _        -> sayLine help
    
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
        
        
--    where 
--      writeSummaryAsCache :: GaugesSummary -> IO GaugesSummary
--      writeSummaryAsCache gs = do
--        writeGaugeCache $ map (\t -> (title t, id t)) (summary gs)
--        return gs

  

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
         
         
     