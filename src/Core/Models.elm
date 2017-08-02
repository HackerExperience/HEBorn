module Core.Models
    exposing
        ( Model
        , State(..)
        , HomeModel
        , SetupModel
        , PlayModel
        , initialModel
        , getConfig
        , connect
        , login
        , logout
        , setupToPlay
        )

import Driver.Websocket.Models as Ws
import Game.Models as Game
import Game.Account.Models as Account
import Game.Dummy as Game
import OS.Models as OS
import Landing.Models as Landing
import Setup.Models as Setup
import Core.Config as Config exposing (Config)
import Core.Messages exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias Model =
    { state : State
    , config : Config
    , seed : Int
    , windowLoaded : Bool
    }


type State
    = Home HomeModel
    | Setup SetupModel
    | Play PlayModel


type alias HomeModel =
    { landing : Landing.Model
    , websocket : Maybe Ws.Model
    , connecting : Maybe Connecting
    }


type alias SetupModel =
    { websocket : Ws.Model
    , game : Game.Model
    , setup : Setup.Model
    }


type alias PlayModel =
    { websocket : Ws.Model
    , game : Game.Model
    , os : OS.Model
    }


type alias Connecting =
    { id : Account.ID
    , username : Account.Username
    , token : Account.Token
    , firstRun : Bool
    }


initialModel : Int -> Config -> Model
initialModel seed config =
    { state = Home initialHome
    , config = config
    , seed = seed
    , windowLoaded = False
    }


connect : Account.ID -> Account.Username -> Account.Token -> Bool -> Model -> Model
connect id username token firstRun ({ state, config } as model) =
    case state of
        Home home ->
            let
                connecting =
                    Just <| Connecting id username token firstRun

                websocket =
                    Just <| Ws.initialModel config.apiWsUrl token

                home_ =
                    { home | websocket = websocket, connecting = connecting }

                state_ =
                    Home home_

                model_ =
                    { model | state = state_ }
            in
                model_

        _ ->
            model


login : Model -> ( Model, Cmd Msg, Dispatch )
login ({ state, config } as model) =
    case state of
        Home ({ connecting, websocket } as home) ->
            case connecting of
                Just ({ token } as connecting) ->
                    -- TODO: add setup check here
                    let
                        websocket_ =
                            Maybe.withDefault
                                (Ws.initialModel config.apiWsUrl token)
                                websocket

                        game =
                            initialGame connecting config

                        ( state_, cmd, dispatch ) =
                            if connecting.firstRun then
                                initialSetup websocket_ game
                                    |> (\( a, b, c ) -> ( Setup a, b, c ))
                            else
                                initialPlay websocket_ game
                                    |> (\( a, b, c ) -> ( Play a, b, c ))

                        model_ =
                            { model | state = state_ }
                    in
                        ( model_, cmd, dispatch )

                Nothing ->
                    ( model, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )


logout : Model -> Model
logout model =
    { model | state = Home initialHome }


getConfig : Model -> Config
getConfig =
    .config


setupToPlay : State -> ( State, Cmd Msg, Dispatch )
setupToPlay state =
    case state of
        Setup { websocket, game } ->
            let
                ( play, cmd, dispatch ) =
                    initialPlay websocket game

                state_ =
                    Play play
            in
                ( state_, cmd, dispatch )

        _ ->
            ( state, Cmd.none, Dispatch.none )



-- internals


initialHome : HomeModel
initialHome =
    { websocket = Nothing
    , landing = Landing.initialModel
    , connecting = Nothing
    }


initialSetup : Ws.Model -> Game.Model -> ( SetupModel, Cmd Msg, Dispatch )
initialSetup ws game =
    let
        ( setup, cmd, msg ) =
            Setup.initialModel game

        cmd_ =
            Cmd.map SetupMsg cmd

        setup_ =
            { websocket = ws
            , game = game
            , setup = setup
            }
    in
        ( setup_, cmd_, msg )


initialPlay : Ws.Model -> Game.Model -> ( PlayModel, Cmd Msg, Dispatch )
initialPlay ws game =
    let
        play_ =
            { websocket = ws
            , game = game
            , os = OS.initialModel
            }
    in
        ( play_, Cmd.none, Dispatch.none )


initialGame : Connecting -> Config -> Game.Model
initialGame { id, username, token } config =
    Game.dummy id username token config
