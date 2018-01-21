module Apps.Bug.Config exposing (..)

import Apps.Bug.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg }
