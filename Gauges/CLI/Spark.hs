module Gauges.CLI.Spark
       (
         Sparkable(..)
       ) where

import Gauges.CLI.Interact (sayLine)
import System.Cmd (rawSystem)
import System.Exit (ExitCode(..))
import Text.JSON (Result(..)) -- todo: probably some way to generalize displayResult and sparkResult

class Sparkable a where
  sparks :: a -> [(String,[Int])]
  showSparks :: a -> IO ()
  showSparks a = sequence_ $ [ (titleSpark name) >> (spark dat) | (name,dat) <- sparks a ]
  sparkResult :: Result a -> IO ()
  sparkResult (Ok a) = showSparks a
  sparkResult (Error s) = putStrLn s

                      
titleSpark :: String -> IO ()
titleSpark s = sayLine $ "Showing spark for: " ++ s
                      
spark :: [Int] -> IO ()
spark nums = do 
  res <- rawSystem "spark" $ map show nums
  case res of
    ExitSuccess   -> return ()
    ExitFailure _ -> putStrLn "You do not have spark installed. Find out more here: https://github.com/holman/spark"
