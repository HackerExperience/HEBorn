module Game.Web.Messages exposing (..)

import Game.Servers.Shared as Servers exposing (CId)
import Game.Meta.Types.Apps.Desktop exposing (Requester)
import Game.Meta.Types.Network as Network


type Msg
    = Login Servers.CId Network.NIP Network.IP String Requester
    | JoinedServer Servers.CId
    | HandleJoinServerFailed Servers.CId
