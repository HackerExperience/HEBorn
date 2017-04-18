module Apps.Instances.Models exposing (..)

import Dict
import OS.WindowManager.Models exposing (WindowID)


type alias InstanceID =
    WindowID


type alias Instances app =
    Dict.Dict InstanceID app


exists : Instances app -> InstanceID -> Bool
exists instances id =
    Dict.member id instances


get : Instances app -> InstanceID -> Maybe app
get instances id =
    Dict.get id instances


new : Instances app -> InstanceID -> app -> Instances app
new instances id initialModel =
    Dict.insert id initialModel instances


remove : Instances app -> InstanceID -> Instances app
remove instances id =
    Dict.remove id instances


open : Instances app -> InstanceID -> app -> Instances app
open instances id initialModel =
    if (exists instances id) then
        instances
    else
        new instances id initialModel


close : Instances app -> InstanceID -> Instances app
close instances id =
    remove instances id


update : Instances app -> InstanceID -> app -> Instances app
update instances id instance =
    let
        fnUpdate inst =
            case inst of
                Just _ ->
                    Just instance

                Nothing ->
                    Nothing
    in
        Dict.update id fnUpdate instances


initialState : Instances app
initialState =
    Dict.empty
