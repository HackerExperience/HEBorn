module Setup.Pages.PickLocation.Requests
    exposing
        ( Response(..)
        , checkLocation
        , receive
        )

import Requests.Types exposing (ConfigSource)
import Game.Servers.Shared as Servers
import Game.Servers.Settings.Check as Check
import Utils.Ports.Map exposing (Coordinates)
import Game.Servers.Settings.Types exposing (..)
import Setup.Pages.PickLocation.Config exposing (..)
import Setup.Pages.PickLocation.Messages exposing (..)
import Requests.Types exposing (ResponseType, ConfigSource, Code(..))


type Response
    = CheckLocation (Maybe String)


checkLocation :
    Config msg
    -> Coordinates
    -> Servers.CId
    -> ConfigSource a
    -> Cmd msg
checkLocation config =
    Location >> check config CheckLocationRequest


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        CheckLocationRequest ( code, data ) ->
            Just <| Check.receiveLocation CheckLocation code data



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
