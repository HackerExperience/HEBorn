module Game.Servers.Settings.Set exposing (request)

import Requests.Requests as Requests
import Requests.Topics as Topics
import Json.Decode as Decode exposing (Value)
import Game.Servers.Settings.Types exposing (..)
import Game.Servers.Shared exposing (..)
import Requests.Types exposing (ConfigSource, Code(..), ResponseType)


request : (ResponseType -> msg) -> Settings -> CId -> ConfigSource a -> Cmd msg
request msg settings cid =
    Requests.request (Topics.serverConfigSet cid) msg (encode settings)
