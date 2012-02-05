module Gauges.API.Data 
       (
         GaugesSummary(..),
         GaugeSummary(..),
         GaugeViewStats(..),
         GaugeTraffic(..)
       ) where

import Gauges.CLI.Display (Displayable(..))
import Gauges.CLI.Spark (Sparkable(..))
import Text.JSON (JSON(..), JSValue(..), fromJSObject, Result)
import Control.Applicative (Applicative(..), Alternative(..), liftA2, (<$>))

data GaugeViewStats = GaugeViewStats { views :: Int, people :: Int } deriving (Show)
data DatedGaugeViewStats = DatedGaugeViewStats { date :: String, dateStats :: GaugeViewStats }

-- Data Representing Summary of All Gauges Belonging to an Account
newtype GaugesSummary = GaugesSummary { summary :: [GaugeSummary] } deriving (Show)
data GaugeSummary = GaugeSummary { gaugeId :: String, 
                                   title :: String, 
                                   stats :: GaugeViewStats 
                                 } deriving (Show)


-- Data Representing Traffic (by month total & history) for a Single Gauge
data GaugeTraffic = GaugeTraffic { total :: GaugeViewStats,
                                   history :: [DatedGaugeViewStats] }
                                   
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

instance JSON GaugeViewStats where
  showJSON gs = error "no need to show json"
  readJSON (JSObject o) = liftA2 GaugeViewStats viewsData peopleData
    where
      obj = fromJSObject o
      viewsData :: Result Int
      viewsData = (aLookup "views" obj) >>= readJSON
      peopleData :: Result Int
      peopleData = (aLookup "people" obj) >>= readJSON
  readJSON _            = fail "expected object"
  
instance JSON DatedGaugeViewStats where  
  showJSON dgs = error "no need to show json"
  readJSON (JSObject o) = liftA2 DatedGaugeViewStats date stats
    where
      date :: Result String      
      date = (aLookup "date" $ fromJSObject o) >>= readJSON
      stats :: Result GaugeViewStats
      stats = readJSON $ JSObject o
     
instance JSON GaugeTraffic where
  showJSON gt = error "no need to show json"                
  readJSON (JSObject o) = liftA2 GaugeTraffic totalData historyData
    where
      obj = fromJSObject o
      totalData = readJSON $ JSObject o
      historyData :: Result [DatedGaugeViewStats]
      historyData = (aLookup "traffic" obj) >>= readJSONs

-- Displayable Instances

-- hacky impl for now
instance Displayable GaugesSummary where
  display gs = unwords $ map display $ summary gs 

instance Displayable GaugeSummary where  
  display gs = (title gs) ++ " " ++ (display $ stats gs)
  
instance Displayable GaugeViewStats where  
  display gss = "views: " ++ (show $ views gss) ++ " people: " ++ (show $ people gss)
  
instance Displayable DatedGaugeViewStats where  
  display gss = (date gss) ++ " | " ++ display (dateStats gss)
  
instance Displayable GaugeTraffic where
  display gt = historyText ++ "\ntotal | " ++ totalText
    where
      historyText = unlines $ map display (history gt)
      totalText = display $ total gt


-- Sparkable Instances
instance Sparkable GaugeTraffic where      
  sparks gt = [("views",viewSpark),("people",peopleSpark)]
    where
      (viewSpark,peopleSpark) = unzip $ map ((\s -> (views s, people s)) . dateStats) $ history gt
      

-- Helper Functions

aLookup :: (Alternative t, Eq a) => a -> [(a, b)] -> t b 
aLookup a as = maybe empty pure (lookup a as)



