module Game.Account.Update exposing (..)

import Maybe
import Core.Dispatch as Dispatch exposing (Dispatch)
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Channels as Websocket
import Driver.Websocket.Reports as Websocket
import Driver.Websocket.Messages as Ws
import Events.Events as Events
import Game.Account.Messages exposing (..)
import Game.Account.Models exposing (..)
import Game.Account.Requests exposing (..)
import Game.Account.Requests.Logout as Logout
import Game.Account.Requests.ServerIndex as ServerIndex
import Game.Models as Game


update :
    Game.Model
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
update game msg model =
    case msg of
        Logout ->
            logout game model

        Request data ->
            response game (receive data) model

        Event data ->
            event game data model



-- internals


logout :
    Game.Model
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
logout game model =
    let
        token =
            getToken model

        cmd =
            Logout.request token game
    in
        ( model, cmd, Dispatch.none )


response :
    Game.Model
    -> Response
    -> Model
    -> ( Model, Cmd msg, Dispatch )
response game response model =
    case response of
        _ ->
            ( model, Cmd.none, Dispatch.none )


event :
    Game.Model
    -> Events.Response
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
event game ev model =
    case ev of
        Events.Report (Websocket.Connected _ id) ->
            let
                dispatch =
                    Dispatch.batch
                        [ Dispatch.websocket
                            (Ws.JoinChannel AccountChannel (Just id))
                        , Dispatch.websocket
                            (Ws.JoinChannel RequestsChannel Nothing)
                        ]
            in
                ( model, Cmd.none, dispatch )

        Events.Report (Websocket.Joined Websocket.AccountChannel) ->
            let
                cmd =
                    ServerIndex.request (Maybe.withDefault "" model.id) game
            in
                ( model, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )
