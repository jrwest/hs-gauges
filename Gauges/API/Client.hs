module Gauges.API.Client       
       (
           Client(token),
           GaugesToken,
           toToken,
           fromToken,
           createClient,
           getResponse,
           getResponseVerbose
       ) where

import Gauges.API.Requestable (Requestable(..), Fetchable(..))
import Gauges.API.Resources (ResourceCollection, Resource)
import Network.Curl (curlGetString, withCurlDo)
import Network.Curl.Code (CurlCode(..))
import Network.Curl.Opts (CurlOption(..))                     

data Client = Client {
    token :: GaugesToken
  } deriving (Show, Eq)             

newtype GaugesToken = GaugesToken String 
                    deriving (Show, Eq)


getResponse :: Fetchable r => Client -> r -> IO (CurlCode,String)
getResponse c r = getWithOpts c r (defaultOpts c)

getResponseVerbose :: Fetchable r => Client -> r -> IO (CurlCode,String)
getResponseVerbose c r = getWithOpts c r (verboseOpts c)

getWithOpts :: Fetchable r => Client -> r -> [CurlOption] -> IO (CurlCode,String)
getWithOpts c r opts = withCurlDo $ curlGetString url opts 
  where 
    url = gaugesURL r
  
-- ugly function    
verboseOpts :: Client -> [CurlOption]    
verboseOpts c = (CurlVerbose True):(defaultOpts c)
    
defaultOpts :: Client -> [CurlOption]
defaultOpts c = [headers]
  where headers = CurlHttpHeaders [gaugesHeader c]


gaugesURL :: Fetchable r => r -> String
gaugesURL r = gaugesBaseURL ++ "/" ++ (path r)

gaugesBaseURL    = "https://secure.gaug.es"
gaugesHeaderName = "X-Gauges-Token"
                                   
gaugesHeader :: Client -> String
gaugesHeader c = gaugesHeaderName ++ ": " ++ (fromToken $ token c)

createClient :: String -> Client
createClient = Client . toToken 

toToken :: String -> GaugesToken
toToken = GaugesToken

fromToken :: GaugesToken -> String
fromToken (GaugesToken s) = s
       
       


