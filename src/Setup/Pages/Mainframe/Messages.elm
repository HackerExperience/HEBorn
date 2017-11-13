module Setup.Pages.Mainframe.Messages exposing (..)

import Requests.Types exposing (ResponseType)


type Msg
    = Mainframe String
    | Validate
    | Request RequestMsg


type RequestMsg
    = CheckNameRequest ResponseType
