module Game.Meta.Types.Components exposing (..)

import Dict exposing (Dict)
import Game.Meta.Types.Components.Type exposing (..)
import Game.Meta.Types.Components.Specs as Specs exposing (Spec)


type alias Id =
    String


type alias Components =
    Dict Id Component


type alias Component =
    { spec : Spec
    , durability : Float
    , available : Bool
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
    getSpec >> Specs.getName


getDescription : Component -> String
getDescription =
    getSpec >> Specs.getDescription


getDurability : Component -> Float
getDurability =
    .durability


getSpec : Component -> Spec
getSpec =
    .spec


getType : Component -> Type
getType =
    getSpec >> Specs.toType


isAvailable : Component -> Bool
isAvailable =
    .available
