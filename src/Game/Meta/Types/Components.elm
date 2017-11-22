module Game.Meta.Types.Components exposing (..)

import Dict exposing (Dict)
import Game.Meta.Types.Components.Type exposing (..)
import Game.Meta.Types.Components.Specs exposing (..)


type alias Id =
    String


type alias Components =
    Dict Id Component


type alias Component =
    { name : String
    , description : String
    , durability : Float
    , available : Bool
    , spec : Spec
    }


empty : Components
empty =
    Dict.empty


get : Id -> Components -> Maybe Component
get =
    Dict.get


member : Id -> Components -> Bool
member =
    Dict.member


insert : Id -> Component -> Components -> Components
insert =
    Dict.insert


remove : Id -> Components -> Components
remove =
    Dict.remove


setAvailable : Bool -> Component -> Component
setAvailable available component =
    { component | available = available }


getName : Component -> String
getName =
    .name


getDescription : Component -> String
getDescription =
    .description


getDurability : Component -> Float
getDurability =
    .durability


getType : Component -> Type
getType =
    .spec >> toType


isAvailable : Component -> Bool
isAvailable =
    .available
