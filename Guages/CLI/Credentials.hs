module Guages.CLI.Credentials 
       (
         credentialPath,
         readCredential,
         validateCredential,
         writeCredential
       ) where

import System.Directory (getHomeDirectory)
import Guages.API.Client (Client, token, fromToken, getResponse, createClient)
import Guages.API.Resources (meR)
import Network.Curl.Code (CurlCode(..))
  
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
    
writeCredential :: Client -> IO ()
writeCredential c = credentialPath >>= (flip writeFile $ (fromToken . token $ c))
    
-- this would probably be a good candidate    
-- function to generalize (maybe is not required)
validateCredential :: String -> IO (Maybe Client)
validateCredential "" = return Nothing
validateCredential s  = do 
  (res,_) <- getResponse candClient meR
  case res of
    CurlOK -> return $ Just candClient
    _      -> return $ Nothing
  where 
    candClient = createClient s
    
credentialFileName :: String
credentialFileName = ".gauges"
    
                  