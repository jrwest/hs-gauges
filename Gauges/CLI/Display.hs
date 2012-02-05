module Gauges.CLI.Display 
       (
         Displayable(..),
         displayResult
       ) where

import Text.JSON (Result(..))
import System.Cmd(rawSystem)
import System.Exit(ExitCode(..))

class Displayable a where
  display :: a -> String
    
displayResult :: Displayable a => Result a -> String
displayResult (Ok a) = display a ++ "\n"
displayResult (Error s) = s

