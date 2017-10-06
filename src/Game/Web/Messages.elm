module Game.Web.Messages exposing (Msg(..), RequestMsg(..))

import Requests.Types exposing (ResponseType)
import Game.Web.Models exposing (Requester)
import Game.Servers.Shared as Servers
import Events.Events as Events
import Game.Web.Models exposing (..)
import OS.SessionManager.WindowManager.Models as WM
import Game.Meta.Types exposing (Context(..))
import Game.Network.Types as Network


type Msg
    = Request RequestMsg
    | FetchUrl String String String Requester
    | Login Network.NIP Network.IP String Requester
    | Event Events.Event


type RequestMsg
    = DNSRequest String Requester ResponseType
