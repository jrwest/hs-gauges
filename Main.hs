module Main (main) where

import Guages.CLI.Credentials (credentialPath,
                               readCredential,
                               validateCredential,
                               writeCredential)
import Guages.API.Client (Client, createClient)  
import System.Directory (doesFileExist)

main = do
  cred <- readClient
  putStrLn $ show cred

-- this is pretty disgusting me thinks?
readClient :: IO Client 
readClient = do
  credsPath <- credentialPath
  hasCreds <- doesFileExist credsPath              
  if hasCreds
    then (putStrLn $ "Using credential from " ++ credsPath) >> readCredential credsPath >>= return . createClient
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
         
         
     