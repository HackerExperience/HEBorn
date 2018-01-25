module Utils.Html.Events exposing (..)

import Html exposing (Attribute)
import Html.Events exposing (on, onWithOptions, keyCode, targetValue)
import Json.Decode as Json


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown handler =
    onWithOptions "keydown"
        { stopPropagation = False
        , preventDefault = True
        }
    <|
        Json.map handler keyCode


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


onClickWithPrevDef : msg -> Attribute msg
onClickWithPrevDef handler =
    onWithOptions "click"
        { stopPropagation = False
        , preventDefault = True
        }
    <|
        Json.succeed handler


onClickWithStopProp : msg -> Attribute msg
onClickWithStopProp handler =
    onWithOptions "click"
        { stopPropagation = True
        , preventDefault = False
        }
    <|
        Json.succeed handler
