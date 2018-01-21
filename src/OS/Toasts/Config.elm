module OS.Toasts.Config exposing (..)

import OS.Toasts.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg }
