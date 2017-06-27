module Core.Messages exposing (Msg(..))

import Game.Messages as Game
import OS.Messages as OS
import Landing.Messages as Landing
import Driver.Websocket.Messages as Ws


type Msg
    = Boot String String
    | Shutdown
    | LandingMsg Landing.Msg
    | GameMsg Game.Msg
    | OSMsg OS.Msg
    | WebsocketMsg Ws.Msg
