module Setup.Pages.Mainframe.Requests
    exposing
        ( Response(..)
        , checkName
        , receive
        )

import Requests.Types exposing (ConfigSource)
import Game.Servers.Shared as Servers
import Game.Servers.Settings.Check as Check
import Game.Servers.Settings.Types exposing (..)
import Setup.Pages.Mainframe.Config exposing (..)
import Setup.Pages.Mainframe.Messages exposing (..)
import Requests.Types exposing (ResponseType, ConfigSource, Code(..))


type Response
    = CheckName Bool


checkName :
    Config msg
    -> String
    -> Servers.CId
    -> ConfigSource a
    -> Cmd msg
checkName config =
    Name >> check config CheckNameRequest


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        CheckNameRequest ( code, data ) ->
            Just <| Check.receiveName CheckName code data



-- internals


check :
    Config msg
    -> (ResponseType -> RequestMsg)
    -> Settings
    -> Servers.CId
    -> ConfigSource a
    -> Cmd msg
check { toMsg } myMsg =
    Check.request (myMsg >> Request >> toMsg)
