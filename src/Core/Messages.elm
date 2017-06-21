module Core.Messages exposing (Msg(..))

import Navigation exposing (Location)
import Game.Messages as Game
import OS.Messages as OS
import Landing.Messages as Landing
import Driver.Websocket.Messages as Websocket


type Msg
    = GameMsg Game.Msg
    | OSMsg OS.Msg
    | LandingMsg Landing.Msg
    | WebsocketMsg Websocket.Msg
    | LocationChangeMsg Location
    | NoOp
