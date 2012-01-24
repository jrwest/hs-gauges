module Gauges.CLI.Interact 
       (
         say,
         sayLine,
         saysLine,
         ask,
         prompt
       ) where

import System.IO (hFlush, stdout)

sayLine :: String -> IO ()
sayLine = putStrLn

saysLine :: [String] -> IO ()
saysLine xs = sayLine $ unwords xs

say :: String -> IO ()
say s = do
  putStr s
  hFlush stdout
  
ask :: String -> IO String  
ask q = do 
  say q
  getLine
  
prompt = ask "> "  