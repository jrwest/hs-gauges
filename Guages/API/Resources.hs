module Guages.API.Resources
       ( 
         ResourceCollection,
         Resource,
         ResourceName,
         ResourceId,
         gauges,
         gauge,
         clients,
         client
       ) where


import Guages.API.Requestable

newtype ResourceCollection = ResourceCollection ResourceName deriving (Show,Eq)

data Resource = Resource ResourceCollection ResourceId deriving (Show,Eq)
--data SubResource = SubResource Resource ResourceName
  
type ResourceName = String
type ResourceId = String

gauges :: ResourceCollection
gauges = ResourceCollection "gauges"

clients :: ResourceCollection
clients = ResourceCollection "clients"

gauge :: ResourceId -> Resource
gauge id = Resource gauges id

client :: ResourceId -> Resource
client id = Resource clients id

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
  

