module Gauges.CLI.GaugeCache 
       (
         writeGaugeCache,
         readGaugeId
       ) where


import System.IO.Error (catch)
import System.Directory (getHomeDirectory)
import Data.Char (toLower)


type GaugeCacheInfo = [(String, String)]

-- todo clean up directory and path building into a module (see Credentials.hs)
gaugeCachePath :: IO String
gaugeCachePath = do
  baseDir <- getHomeDirectory
  return $ baseDir ++ "/" ++ gaugeCacheFileName
  
gaugeCacheFileName :: String
gaugeCacheFileName = ".gauges_cache"

writeGaugeCache :: GaugeCacheInfo -> IO ()
writeGaugeCache cacheInfo = do
  path <- gaugeCachePath
  writeFile path cacheData
  where 
    cacheData = unlines $ map (cacheLine) cacheInfo
    cacheLine :: (String,String) -> String
    cacheLine (title,id) = title ++ ":" ++ id
    
-- can generalize this to any monad or monad trans?
readGaugeId :: String -> IO (Maybe String)
readGaugeId name = do                                   
  cache <- readGaugeCache
  return $ lookup (map toLower name) cache
    
readGaugeCache :: IO [(String,String)]
readGaugeCache = do
  path <- gaugeCachePath  
  contents <- catch (readFile path) (\_ -> return "")
  return $ parseGaugeCache $ lines contents
  
parseGaugeCache :: [String] -> GaugeCacheInfo
parseGaugeCache xs = map parseCacheLine xs
  
parseCacheLine s = (map toLower key, value)  
  where
    (key,_:value) = break (==':') s
  
