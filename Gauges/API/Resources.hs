module Gauges.API.Resources
       ( 
         ResourceCollection,
         Resource,
         ResourceName,
         ResourceId,
         gaugesR,
         gaugeR,
         gaugeTrafficR,
         clientsR,
         clientR,
         meR
       ) where


import Gauges.API.Requestable

newtype ResourceCollection = ResourceCollection { resourceName :: ResourceName } deriving (Show,Eq)

data Resource = Resource { resourceCollection :: ResourceCollection,
                           resourceId         :: ResourceId 
                         } deriving (Show,Eq)
data SubResource = SubResource { parentResource  :: Resource, 
                                 subResourceName :: ResourceName, 
                                 subResourceDate :: ResourceDate 
                               } deriving (Show,Eq)
                               
  
type ResourceName = String
type ResourceId = String
type ResourceDate = String

meR :: ResourceCollection
meR = ResourceCollection "me"

gaugesR :: ResourceCollection
gaugesR = ResourceCollection "gauges"

clientsR :: ResourceCollection
clientsR = ResourceCollection "clients"

gaugeR :: ResourceId -> Resource
gaugeR id = Resource gaugesR id

gaugeTrafficR :: ResourceId -> ResourceDate -> SubResource
gaugeTrafficR id date = SubResource (gaugeR id) "traffic" date

clientR :: ResourceId -> Resource
clientR id = Resource clientsR id

-- Requestable Instances
instance Requestable ResourceCollection where
  pathParts (ResourceCollection name) = [name]
  
instance Requestable Resource where  
  pathParts (Resource (ResourceCollection colName) resName) = [colName, resName]
  
instance Requestable SubResource where
  pathParts sr = [resourceName . resourceCollection . parentResource $ sr, resourceId . parentResource $ sr, subResourceName sr] 

-- Fetchable Instances  
instance Fetchable ResourceCollection where  
  query _ = []
  
instance Fetchable Resource where  
  query _ = []
  
-- add support for date, etc option
instance Fetchable SubResource where  
  query sr = [("date", subResourceDate sr)]  