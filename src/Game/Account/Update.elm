module Game.Account.Update exposing (..)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Messages as Core
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Channels as Ws
import Driver.Websocket.Reports as Ws
import Driver.Websocket.Messages as Ws
import Events.Events as Events
import Game.Account.Bounces.Update as Bounces
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

        BouncesMsg msg ->
            let
                ( bounces, cmd, dispatch ) =
                    Bounces.update game msg model.bounces

                cmd_ =
                    Cmd.map BouncesMsg cmd

                model_ =
                    { model | bounces = bounces }
            in
                ( model_, cmd_, dispatch )

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
        model_ =
            { model | logout = True }

        token =
            getToken model

        cmd =
            Logout.request token game
    in
        ( model_, cmd, Dispatch.none )


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
    -> Events.Event
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
event game ev model =
    case ev of
        Events.Report (Ws.Connected _) ->
            let
                dispatch =
                    Dispatch.batch
                        [ Dispatch.websocket
                            (Ws.JoinChannel AccountChannel (Just model.id))
                        , Dispatch.websocket
                            (Ws.JoinChannel RequestsChannel Nothing)
                        ]
            in
                ( model, Cmd.none, dispatch )

        Events.Report Ws.Disconnected ->
            let
                dispatch =
                    if model.logout then
                        Dispatch.core Core.Shutdown
                    else
                        Dispatch.none
            in
                ( model, Cmd.none, dispatch )

        Events.Report (Ws.Joined Ws.AccountChannel) ->
            let
                cmd =
                    ServerIndex.request model.id game
            in
                ( model, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )
