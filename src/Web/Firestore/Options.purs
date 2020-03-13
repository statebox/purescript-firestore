module Web.Firestore.Options where

import Prelude
import Data.Argonaut (class EncodeJson, jsonEmptyObject, (:=), (:=?), (~>), (~>?))
import Data.Lens (Iso', Lens', iso, lens, view)
import Data.Maybe (Maybe(..))

newtype Options = Options
  { apiKey :: Maybe String
  , appId :: Maybe String
  , authDomain :: Maybe String
  , databaseUrl :: Maybe String
  , measurementId :: Maybe String -- TODO: should this be there or not?
  , messagingSenderId :: Maybe String
  , projectId :: String
  , storageBucket :: Maybe String
  }

instance showOptions :: Show Options where
  show (Options r) = "Options: " <> show r

instance eqOptions :: Eq Options where
  eq (Options r) (Options r') = eq r r'

instance encodeJsonOptions :: EncodeJson Options where
  encodeJson opt
    =   "apiKey"            :=? view apiKey            opt
    ~>? "appId"             :=? view appId             opt
    ~>? "authDomain"        :=? view authDomain        opt
    ~>? "databaseUrl"       :=? view databaseUrl       opt
    ~>? "measurementId"     :=? view measurementId     opt
    ~>? "messagingSenderId" :=? view messagingSenderId opt
    ~>? "projectId"         :=  view projectId         opt
    ~>  "storageBucket"     :=? view storageBucket     opt
    ~>? jsonEmptyObject

options :: String -> Options
options pId = Options
  { apiKey : Nothing
  , appId : Nothing
  , authDomain : Nothing
  , databaseUrl : Nothing
  , measurementId : Nothing
  , messagingSenderId : Nothing
  , projectId : pId
  , storageBucket : Nothing
  }

optionsIso :: Iso' Options { apiKey :: Maybe String
                           , appId :: Maybe String
                           , authDomain :: Maybe String
                           , databaseUrl :: Maybe String
                           , measurementId :: Maybe String
                           , messagingSenderId :: Maybe String
                           , projectId :: String
                           , storageBucket :: Maybe String
                           }
optionsIso = iso (\(Options r) -> r) Options

apiKey :: Lens' Options (Maybe String)
apiKey = lens (_.apiKey) (_ {apiKey = _}) >>> optionsIso

appId :: Lens' Options (Maybe String)
appId = lens (_.appId) (_ {appId = _}) >>> optionsIso

authDomain :: Lens' Options (Maybe String)
authDomain = lens (_.authDomain) (_ {authDomain = _}) >>> optionsIso

databaseUrl :: Lens' Options (Maybe String)
databaseUrl = lens (_.databaseUrl) (_ {databaseUrl = _}) >>> optionsIso

measurementId :: Lens' Options (Maybe String)
measurementId = lens (_.measurementId) (_ {measurementId = _}) >>> optionsIso

messagingSenderId :: Lens' Options (Maybe String)
messagingSenderId = lens (_.messagingSenderId) (_ {messagingSenderId = _}) >>> optionsIso

projectId :: Lens' Options String
projectId = lens (_.projectId) (_ {projectId = _}) >>> optionsIso

storageBucket :: Lens' Options (Maybe String)
storageBucket = lens (_.storageBucket) (_ {storageBucket = _}) >>> optionsIso
