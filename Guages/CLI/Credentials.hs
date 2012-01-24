module Guages.CLI.Credentials 
       (
         credentialPath,
         readCredential
       ) where

import System.Directory (getHomeDirectory)
  
credentialPath :: IO String
credentialPath = do
    baseDir <- getHomeDirectory
    return $ baseDir ++ "/" ++ credentialFileName

readCredential :: String -> IO String
readCredential path = do
  fileContents <- readFile path
  return $ cred fileContents
  where
    cred [] = ""
    cred cs = head $ lines cs
    
credentialFileName :: String
credentialFileName = ".gauges"
    
                  