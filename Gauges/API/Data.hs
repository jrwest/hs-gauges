module Gauges.API.Data 
       (
         GaugesSummary(..),
         GaugeSummary(..),
         GaugeSummaryStats(..)
       ) where

import Text.JSON (JSON(..), JSValue(..), fromJSObject, Result)
import Control.Applicative (Applicative(..), Alternative(..), liftA2, (<$>))

newtype GaugesSummary = GaugesSummary [GaugeSummary] deriving (Show)
-- id, title, views, people
data GaugeSummary = GaugeSummary { id :: String, 
                                   title :: String, 
                                   stats :: GaugeSummaryStats 
                                 } deriving (Show)
-- view count, people count
data GaugeSummaryStats = GaugeSummaryStats { views :: Int, people :: Int } deriving (Show)

instance JSON GaugesSummary where
  showJSON = error "not showing JSON"
  readJSON (JSObject o) = GaugesSummary <$> summaries
    where
      obj = fromJSObject o
      summaries :: Result [GaugeSummary]
      summaries = (aLookup "gauges" obj) >>= readJSONs
    
  readJSON _            = error "not an object"

instance JSON GaugeSummary where
  showJSON gs = error "We have no need to showJSON data right now"
  readJSON (JSObject o) = GaugeSummary <$> idData <*> titleData <*> summaryData
    where 
      obj = fromJSObject o    
      titleData :: Result String
      titleData = (aLookup "title" obj) >>= readJSON
      idData :: Result String
      idData = (aLookup "id" obj) >>= readJSON 
      summaryData = (aLookup "today" obj) >>= readJSON
  readJSON _            = error "not an object"

instance JSON GaugeSummaryStats where
  showJSON gs = error "no need to show json"
  readJSON (JSObject o) = liftA2 GaugeSummaryStats viewsData peopleData
    where
      obj = fromJSObject o
      viewsData :: Result Int
      viewsData = (aLookup "views" obj) >>= readJSON
      peopleData :: Result Int
      peopleData = (aLookup "people" obj) >>= readJSON
  readJSON _            = fail "expected object"
     

aLookup :: (Alternative t, Eq a) => a -> [(a, b)] -> t b 
aLookup a as = maybe empty pure (lookup a as)



