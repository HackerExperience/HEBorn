module Utils.Html.Attributes exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (attribute)
import Game.Meta.Types.Context exposing (Context(..))
import Apps.Apps as Apps
import Apps.Models as Apps


boolAttr : String -> Bool -> Attribute msg
boolAttr attr boolean =
    let
        value =
            if boolean then
                "1"
            else
                "0"
    in
        attribute attr value


boolAttrYN : String -> Bool -> Attribute msg
boolAttrYN attr boolean =
    let
        value =
            if boolean then
                "Y"
            else
                "N"
    in
        attribute attr value


selectedAttr : Bool -> Attribute msg
selectedAttr =
    boolAttr "selected"


hasInstance : Bool -> Attribute msg
hasInstance =
    boolAttrYN "hasinst"


iconAttr : String -> Attribute msg
iconAttr =
    attribute "icon"


idAttr : String -> Attribute msg
idAttr =
    attribute "id"


decoratedAttr : Bool -> Attribute msg
decoratedAttr =
    boolAttrYN "decorated"


appAttr : Apps.App -> Attribute msg
appAttr =
    Apps.name
        >> attribute "app"


gameVersionAttr : String -> Attribute msg
gameVersionAttr =
    attribute "game-version"


gameModeAttr : String -> Attribute msg
gameModeAttr =
    attribute "game-mode"


activeContextAttr : Context -> Attribute msg
activeContextAttr =
    activeContextValue
        >> attribute "context"


activeContextValue : Context -> String
activeContextValue c =
    case c of
        Gateway ->
            "gate"

        Endpoint ->
            "end"


openAttr : Bool -> Attribute msg
openAttr open =
    attribute "open" <|
        if open then
            "open"
        else
            "0"
