module Utils.Html.Attributes exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (attribute)
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)


-- ONLY PUT HERE ATTRIBUTES THAT REQUIRES MAPPING OR PIPES
-- AND THAT WILL BE USED IN MORE THAN ONE PLACE
-- Tags:


idAttrTag : String
idAttrTag =
    "id"


appAttrTag : String
appAttrTag =
    "app"


activeContextAttrTag : String
activeContextAttrTag =
    "context"



-- Per Type Attrs:


boolAttr : String -> Bool -> Attribute msg
boolAttr attr boolean =
    let
        value =
            if boolean then
                "Y"
            else
                "N"
    in
        attribute attr value



-- Content-specific Attrs:


idAttr : String -> Attribute msg
idAttr =
    attribute idAttrTag


appAttr : String -> Attribute msg
appAttr =
    attribute appAttrTag


activeContextAttr : Context -> Attribute msg
activeContextAttr =
    activeContextValue
        >> attribute activeContextAttrTag



-- Utils:


activeContextValue : Context -> String
activeContextValue c =
    case c of
        Gateway ->
            "gate"

        Endpoint ->
            "end"
