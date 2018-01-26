module Setup.Pages.Mainframe.Messages exposing (..)

import Game.Servers.Shared exposing (CId)


type Msg
    = Mainframe String
    | Validate
    | Checked CId Bool
