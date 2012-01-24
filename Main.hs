module Main (main) where

import Guages.CLI.Credentials (credentialPath,
                               readCredential)
import System.Directory (doesFileExist)

main = do
  cred <- readCred
  putStrLn cred

readCred :: IO String
readCred = do
  credsPath <- credentialPath
  hasCreds <- doesFileExist credsPath              
  if hasCreds
    then (putStrLn $ "Using credential from " ++ credsPath) >> readCredential credsPath
    else newCred         
            
         
newCred :: IO String          
newCred = do
  putStrLn $ "Welcome to Guages"
  putStrLn $ "Please enter your API key: "
  getLine  
         
         
     