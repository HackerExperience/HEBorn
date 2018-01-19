module OS.SessionManager.Dock.Config exposing (..)

import OS.SessionManager.Dock.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg }
