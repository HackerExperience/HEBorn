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
    boolAttr "data-selected"


hasInstance : Bool -> Attribute msg
hasInstance =
    boolAttrYN "data-hasinst"


iconAttr : String -> Attribute msg
iconAttr =
    attribute "data-icon"


idAttr : String -> Attribute msg
idAttr =
    attribute "data-id"


dataDecorated : Bool -> Attribute msg
dataDecorated =
    boolAttrYN "data-decorated"


openAttr : Bool -> Attribute msg
openAttr open =
    attribute "data-open" <|
        if open then
            "open"
        else
            "0"
