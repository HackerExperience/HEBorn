module Utils.Html.Attributes exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (attribute)


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


dataSelected : Bool -> Attribute msg
dataSelected =
    boolAttr "data-selected"
