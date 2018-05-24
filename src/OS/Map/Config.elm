module OS.Map.Config exposing (..)

import OS.Map.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg }
