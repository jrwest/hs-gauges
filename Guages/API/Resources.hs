module Guages.API.Resources
       ( 
         ResourceCollection,
         Resource,
         ResourceName,
         ResourceId,
         gaugesR,
         gaugeR,
         clientsR,
         clientR,
         meR
       ) where


import Guages.API.Requestable

newtype ResourceCollection = ResourceCollection ResourceName deriving (Show,Eq)

data Resource = Resource ResourceCollection ResourceId deriving (Show,Eq)
--data SubResource = SubResource Resource ResourceName
  
type ResourceName = String
type ResourceId = String

meR :: ResourceCollection
meR = ResourceCollection "me"

gaugesR :: ResourceCollection
gaugesR = ResourceCollection "gauges"

clientsR :: ResourceCollection
clientsR = ResourceCollection "clients"

gaugeR :: ResourceId -> Resource
gaugeR id = Resource gaugesR id

clientR :: ResourceId -> Resource
clientR id = Resource clientsR id

-- Requestable Instances
instance Requestable ResourceCollection where
  pathParts (ResourceCollection name) = [name]
  
instance Requestable Resource where  
  pathParts (Resource (ResourceCollection colName) resName) = [colName, resName]
  

-- Fetchable Instances  
instance Fetchable ResourceCollection where  
  query _ = []
  
instance Fetchable Resource where  
  query _ = []
  

