module Gauges.API.Data 
       (
         GaugesSummary(..),
         GaugeSummary(..),
         GaugeSummaryStats(..)
       ) where

import Gauges.CLI.Display (Displayable(..))
import Text.JSON (JSON(..), JSValue(..), fromJSObject, Result)
import Control.Applicative (Applicative(..), Alternative(..), liftA2, (<$>))

newtype GaugesSummary = GaugesSummary { summary :: [GaugeSummary] } deriving (Show)
data GaugeSummary = GaugeSummary { gaugeId :: String, 
                                   title :: String, 
                                   stats :: GaugeSummaryStats 
                                 } deriving (Show)
data GaugeSummaryStats = GaugeSummaryStats { views :: Int, people :: Int } deriving (Show)

-- JSON Instances
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
     

-- Displayable Instances

-- hacky impl for now
instance Displayable GaugesSummary where
  display gs = unwords $ map display $ summary gs 

instance Displayable GaugeSummary where  
  display gs = (title gs) ++ " " ++ (display $ stats gs)
  
instance Displayable GaugeSummaryStats where  
  display gss = "views: " ++ (show $ views gss) ++ " people: " ++ (show $ people gss)
  

-- Helper Functions

aLookup :: (Alternative t, Eq a) => a -> [(a, b)] -> t b 
aLookup a as = maybe empty pure (lookup a as)



