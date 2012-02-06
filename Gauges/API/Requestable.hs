module Gauges.API.Requestable 
       (
         Requestable(..),
         Fetchable(..)         
       ) where

import Data.List (intercalate)

class Requestable a where
  pathParts :: a -> [String]
  path :: a -> String
  path = intercalate "/" . pathParts

class (Requestable a) => Fetchable a where
  query :: a -> [(String,String)]           
  queryString :: a -> String
  queryString a = intercalate "&" [ key ++ "=" ++ value | (key,value) <- query a ]
