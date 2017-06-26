module Utils.Html exposing (onKeyDown)

import Html
import Html.Events exposing (on, keyCode)
import Json.Decode as Json


onKeyDown : (Int -> msg) -> Html.Attribute msg
onKeyDown tagger =
    on "keydown" (Json.map tagger keyCode)
