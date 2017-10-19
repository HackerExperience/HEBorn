module Setup.Messages exposing (..)

import Json.Encode exposing (Value)
import Setup.Types exposing (..)
import Requests.Types exposing (ResponseType)


type Msg
    = Msg
    | FinishLoading
    | HandleJoinedAccount



--= MapClick ValueValue
--| GeoLocResp Value
--| GeoRevResp Value
--| ResetLoc
--| GoPage Page
--| GoOS
--| Request RequestMsg


type RequestMsg
    = SetupRequest ResponseType
