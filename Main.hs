module Main (main) where

import Guages.CLI.Credentials (credentialPath,
                               readCredential,
                               validateCredential,
                               writeCredential)
import Guages.API.Client (Client, createClient, getResponse)  
import Guages.API.Resources (gaugesR)
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
  case res of 
    CurlOK -> putStrLn resp
    _      -> putStrLn "Failed to download information about gauges."

help = putStrLn "USAGE: gauges [COMMAND]"
  

-- this is pretty disgusting me thinks?
readClient :: IO Client 
readClient = do
  credsPath <- credentialPath
  hasCreds <- doesFileExist credsPath              
  if hasCreds
    then (putStrLn $ "Using credential from " ++ credsPath) >> readCredential credsPath
    else newAndValidate
    where
      newAndValidate :: IO Client
      newAndValidate = newClient >>= validateCredential >>= \mbC -> case mbC of 
        Just cl -> writeCredential cl >> return cl
        Nothing -> (putStrLn "invalid API Key") >>  newAndValidate
            
         
newClient :: IO String
newClient = do
  putStrLn $ "You have not setup an API Key. Please enter one: "
  getLine  
         
         
     