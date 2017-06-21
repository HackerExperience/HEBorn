module Game.Account.Update exposing (..)

import Maybe
import Driver.Websocket.Reports as Websocket
import Driver.Websocket.Channels as Websocket
import Events.Events as Events
import Game.Account.Messages exposing (..)
import Game.Account.Models exposing (..)
import Game.Account.Requests exposing (..)
import Game.Account.Requests.Logout as Logout
import Game.Account.Requests.ServerIndex as ServerIndex
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game


update :
    Msg
    -> Model
    -> Game.Model
    -> ( Model, Cmd Msg, Dispatch )
update msg model game =
    case msg of
        Login token id ->
            login token id model game

        Logout ->
            logout model game

        Request data ->
            response (receive data) model game

        Event data ->
            event data model game



-- internals


login :
    Token
    -> String
    -> Model
    -> Game.Model
    -> ( Model, Cmd Msg, Dispatch )
login token id model game =
    let
        model1 =
            setToken model (Just token)

        model_ =
            { model1 | id = Just id }
    in
        ( model_, Cmd.none, Dispatch.none )


logout :
    Model
    -> Game.Model
    -> ( Model, Cmd Msg, Dispatch )
logout model game =
    case getToken model of
        Just token ->
            let
                model_ =
                    setToken model Nothing

                cmd =
                    Logout.request token game.meta.config
            in
                ( model_, cmd, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )


response :
    Response
    -> Model
    -> Game.Model
    -> ( Model, Cmd msg, Dispatch )
response response model game =
    case response of
        LogoutResponse Logout.OkResponse ->
            ( model, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )


event :
    Events.Response
    -> Model
    -> Game.Model
    -> ( Model, Cmd Msg, Dispatch )
event ev model game =
    case ev of
        Events.Report (Websocket.Joined Websocket.AccountChannel) ->
            let
                cmd =
                    ServerIndex.request (Maybe.withDefault "" model.id) game.meta.config
            in
                ( model, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )
