module Core.Messages exposing (Msg(..))

import Game.Messages as Game
import Game.Account.Models as Account
import OS.Messages as OS
import Landing.Messages as Landing
import Setup.Messages as Setup
import Driver.Websocket.Messages as Ws
import Core.Error as Error exposing (Error)


type Msg
    = MultiMsg (List Msg)
    | HandleConnected
    | HandleBoot Account.ID Account.Username Account.Token
    | HandleShutdown
    | HandleCrash Error
    | HandlePlay
    | LandingMsg Landing.Msg
    | SetupMsg Setup.Msg
    | GameMsg Game.Msg
    | OSMsg OS.Msg
    | WebsocketMsg Ws.Msg
    | LoadingEnd Int
