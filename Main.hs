module Main (main) where

-- this file really needs cleaning up and things moved out of it

import Gauges.CLI.Credentials (credentialPath,
                               readCredential,
                               validateCredential,
                               writeCredential)
import Gauges.CLI.Interact (sayLine, saysLine, say, ask, prompt)
import Gauges.API.Client (Client, createClient, getResponse)  
import Gauges.API.Resources (gaugesR)
import Gauges.API.Data (GaugesSummary)
import System.Directory (doesFileExist)
import System (getArgs)
import Network.Curl.Code (CurlCode(..))
import Text.JSON (Result, decode)

main = do
  args <- getArgs
  case args of 
    ["--help"]  -> help
    ["-h"]      -> help
    ["help"]    -> help
    []          -> startInteractive
    command     -> startAuthorized command
    
runAuthorized :: Client -> [String] -> IO () -> IO ()
runAuthorized cl command help = do
  case command of 
    ["list"] -> listCommand cl
    _        -> help
    
runInteractive :: Client -> IO ()
runInteractive cl = do
  command <- prompt  
  case command of
    ["quit"] -> endInteractive
    ["q"]    -> endInteractive
    ["help"] -> interactiveHelp >> runInteractive cl 
    []       -> runInteractive cl
    _        -> runAuthorized cl command interactiveHelp >> runInteractive cl    
  
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
endInteractive = sayLine "Goodbye!"      
  
listCommand :: Client -> IO ()  
listCommand c = do  
  (res,resp) <- getResponse c gaugesR
  say $ case res of 
    CurlOK ->  show (decode resp :: Result GaugesSummary)
    _      -> "Failed to download information about gauges."

help = sayLine "USAGE: gauges [COMMAND]"

interactiveHelp = say "This would be where the interactive mode help goes"
  

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
         
         
     