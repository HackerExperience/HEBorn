module Utils.Html.Events exposing (..)

import Html exposing (Attribute)
import Html.Events exposing (on, onWithOptions, keyCode, targetValue)
import Json.Decode as Json


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown handler =
    on "keydown" <| Json.map handler keyCode


onChange : (String -> msg) -> Attribute msg
onChange handler =
    on "change" <| Json.map handler targetValue


onClickMe : msg -> Attribute msg
onClickMe handler =
    onWithOptions "click"
        { stopPropagation = True
        , preventDefault = True
        }
    <|
        Json.succeed handler
