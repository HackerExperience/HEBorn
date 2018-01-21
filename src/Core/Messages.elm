module Core.Messages exposing (Msg(..), unroll)

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


unroll : Msg -> List Msg
unroll msg =
    case msg of
        MultiMsg list ->
            unrollHelper [] list

        _ ->
            [ msg ]


unrollHelper : List Msg -> List Msg -> List Msg
unrollHelper accum list =
    case list of
        msg :: remains ->
            case msg of
                MultiMsg list ->
                    unrollHelper accum list ++ accum

                _ ->
                    unrollHelper (msg :: accum) remains

        [] ->
            accum
