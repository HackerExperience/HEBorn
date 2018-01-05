module Utils.Svg.Events exposing (..)

import Json.Decode as Json
import Svg exposing (Attribute)
import VirtualDom


onClickMe : msg -> Attribute msg
onClickMe handler =
    VirtualDom.onWithOptions "click"
        { stopPropagation = True
        , preventDefault = True
        }
    <|
        Json.succeed handler
