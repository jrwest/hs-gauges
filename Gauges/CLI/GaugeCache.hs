module Gauges.CLI.GaugeCache 
       (
         writeGaugeCache
       ) where


import System.IO.Error (catch)
import System.Directory (getHomeDirectory)


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
    
--readGaugeCache :: IO (Maybe GaugeCacheInfo)
--readGaugeCache = do
--  path <- gaugeCachePath
--  contents <- catch (readFile path) (\_ -> return Nothing)
  