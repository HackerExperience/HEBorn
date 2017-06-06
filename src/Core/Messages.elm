module Core.Messages exposing (CoreMsg(..))

import Navigation exposing (Location)
import Game.Messages exposing (GameMsg(..))
import OS.Messages exposing (OSMsg(..))
import Landing.Messages exposing (LandMsg(..))
import Driver.Websocket.Messages


type CoreMsg
    = MsgGame Game.Messages.GameMsg
    | MsgOS OS.Messages.OSMsg
    | MsgLand Landing.Messages.LandMsg
    | MsgWebsocket Driver.Websocket.Messages.Msg
    | OnLocationChange Location
    | NoOp
