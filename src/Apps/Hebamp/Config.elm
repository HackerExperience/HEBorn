module Apps.Hebamp.Config exposing (..)

import Html exposing (Attribute)
import Game.Meta.Types.Desktop.Apps exposing (Reference)
import Apps.Hebamp.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , reference : Reference
    , draggable : Attribute msg
    , windowMenu : Attribute msg
    , onCloseApp : msg
    }
