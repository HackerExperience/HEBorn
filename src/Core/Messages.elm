module Core.Messages exposing (Msg(..), unroll)

import ContextMenu
import Json.Decode exposing (Value)
import Game.Messages as Game
import Game.Account.Models as Account
import OS.Messages as OS
import Landing.Messages as Landing
import Setup.Messages as Setup
import Driver.Websocket.Channels as Ws
import Driver.Websocket.Messages as Ws
import Core.Error as Error exposing (Error)


type Msg
    = BatchMsg (List Msg)
    | HandleConnected
    | HandleBoot Account.ID Account.Username Account.Token
    | HandleShutdown
    | HandleCrash Error
    | HandlePlay
    | HandleEvent Ws.Channel (Result String ( String, Value ))
    | LandingMsg Landing.Msg
    | SetupMsg Setup.Msg
    | GameMsg Game.Msg
    | OSMsg OS.Msg
    | WebsocketMsg Ws.Msg
    | LoadingEnd Int
    | MenuMsg ContextMenuShit


type alias ContextMenuShit =
    ContextMenu.Msg (List (List ( ContextMenu.Item, Msg )))


unroll : Msg -> List Msg
unroll msg =
    case msg of
        BatchMsg list ->
            unrollHelper [] list

        _ ->
            [ msg ]


unrollHelper : List Msg -> List Msg -> List Msg
unrollHelper accum list =
    case list of
        msg :: remains ->
            case msg of
                BatchMsg list ->
                    unrollHelper accum list ++ accum

                _ ->
                    unrollHelper (msg :: accum) remains

        [] ->
            accum
