module Gauges.CLI.Display 
       (
         
       ) where

class Displayable a where
  display :: a -> String
