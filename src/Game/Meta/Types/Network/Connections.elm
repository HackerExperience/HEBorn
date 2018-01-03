module Game.Meta.Types.Network.Connections exposing (..)

import Dict exposing (Dict)
import Game.Meta.Types.Network exposing (NIP)


type alias Id =
    NIP


type alias Connections =
    Dict Id Connection


type alias Connection =
    { name : String
    , available : Bool
    }


empty : Connections
empty =
    Dict.empty


get : Id -> Connections -> Maybe Connection
get =
    Dict.get


member : Id -> Connections -> Bool
member =
    Dict.member


insert : Id -> Connection -> Connections -> Connections
insert =
    Dict.insert


remove : Id -> Connections -> Connections
remove =
    Dict.remove


setAvailable : Bool -> Connection -> Connection
setAvailable available connection =
    { connection | available = available }


getName : Connection -> String
getName =
    .name


isAvailable : Connection -> Bool
isAvailable =
    .available
