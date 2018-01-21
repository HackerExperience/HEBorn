module OS.Config exposing (..)

import Time exposing (Time)
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Storyline.Models as Story
import OS.SessionManager.Config as SessionManager
import OS.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , story : Story.Model
    , account : Account.Model
    , lastTick : Time
    , activeServer : Servers.Server
    }


smConfig : Config msg -> SessionManager.Config msg
smConfig { account, story, activeServer, lastTick, toMsg } =
    { toMsg = SessionManagerMsg >> toMsg
    , lastTick = lastTick
    , account = account
    , story = story
    , activeServer = activeServer
    , activeContext = Account.getContext account
    }
