module Main (main) where

import Gauges.CLI.Credentials (credentialPath,
                               readCredential,
                               validateCredential,
                               writeCredential)
import Gauges.CLI.Interact (sayLine, saysLine, say, ask)
import Gauges.API.Client (Client, createClient, getResponse)  
import Gauges.API.Resources (gaugesR)
import System.Directory (doesFileExist)
import System (getArgs)
import Network.Curl.Code (CurlCode(..))

main = do
  args <- getArgs
  case args of 
    ["--help"]  -> help
    ["-h"]      -> help
    ["help"]    -> help
    []          -> help
    command     -> runAuthorized command
  
runAuthorized :: [String] -> IO ()
runAuthorized command = do
  client <- readClient
  case command of 
    ["list"] -> listCommand client
    _        -> help
  
listCommand :: Client -> IO ()  
listCommand c = do  
  (res,resp) <- getResponse c gaugesR
  say $ case res of 
    CurlOK ->  resp
    _      -> "Failed to download information about gauges."

help = say "USAGE: gauges [COMMAND]"
  

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
         
         
     