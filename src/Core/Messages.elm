module Core.Messages exposing (Msg(..))

import Game.Messages as Game
import OS.Messages as OS
import Landing.Messages as Landing
import Driver.Websocket.Messages as Websocket


type Msg
    = Bootstrap String String
    | LandingMsg Landing.Msg
    | GameMsg Game.Msg
    | OSMsg OS.Msg
    | WebsocketMsg Websocket.Msg
