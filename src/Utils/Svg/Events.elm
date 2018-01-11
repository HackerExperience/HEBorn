module Utils.Svg.Events exposing (..)

import Json.Decode as Json
import Svg exposing (Attribute)
import VirtualDom


onClickWithPrevent : msg -> Attribute msg
onClickWithPrevent handler =
    VirtualDom.onWithOptions "click"
        { stopPropagation = False
        , preventDefault = True
        }
    <|
        Json.succeed handler


onMouseDownWithPrevent : msg -> Attribute msg
onMouseDownWithPrevent handler =
    VirtualDom.onWithOptions "mousedown"
        { stopPropagation = False
        , preventDefault = True
        }
    <|
        Json.succeed handler
