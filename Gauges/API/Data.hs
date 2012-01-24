module Gauges.API.Data 
       (
         
       ) where

import Text.JSON (JSON(..), JSValue(..), fromJSObject)
import Control.Applicative (Applicative(..), Alternative(..), liftA2, (<$>))

newtype GaugesSummary = GaugesSummary [GaugeSummary]  
-- id, title, views, people
data GaugeSummary = GuageSummary String Int Int

data TestGaugeSummary = TestGaugeSummary String String

instance JSON TestGaugeSummary where  
  showJSON gs = error "We have no need to show Data JSON right now"
  readJSON (JSObject o) = 
    let obj = fromJSObject o
    in liftA2 TestGaugeSummary (show <$> (aLookup "title" obj)) (show <$> (aLookup "id" obj)) -- its failing to compile here because these return JSValue not 
  readJSON _            = fail "not an object"

aLookup :: (Alternative t, Eq a) => a -> [(a, b)] -> t b 
aLookup a as = maybe empty pure (lookup a as)



