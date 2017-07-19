module Core.Models
    exposing
        ( Model(..)
        , HomeModel
        , PlayModel
        , initialModel
        , connect
        , login
        , logout
        , getConfig
        )

import Driver.Websocket.Models as Ws
import Game.Models as Game
import Game.Account.Models as Account
import Game.Dummy as Game
import OS.Models as OS
import Landing.Models as Landing
import Core.Config as Config exposing (Config)


type Model
    = Home HomeModel
    | Play PlayModel


type alias HomeModel =
    { landing : Landing.Model
    , websocket : Maybe Ws.Model
    , config : Config
    , seed : Int
    , connection : Maybe ProbableConnection
    }


type alias ProbableConnection =
    { id : Account.ID
    , username : Account.Username
    , token : Account.Token
    }


type alias PlayModel =
    { game : Game.Model
    , os : OS.Model
    , websocket : Ws.Model
    , config : Config
    , seed : Int
    }


initialModel : Int -> Config -> Model
initialModel seed config =
    Home
        { landing = Landing.initialModel
        , websocket = Nothing
        , config = config
        , seed = seed
        , connection = Nothing
        }


connect : Account.ID -> Account.Username -> Account.Token -> Model -> Model
connect id username token model =
    case model of
        Home model ->
            let
                websocket =
                    Just (Ws.initialModel model.config.apiWsUrl token)
            in
                Home
                    { model
                        | websocket = websocket
                        , connection =
                            Just (ProbableConnection id username token)
                    }

        _ ->
            model


login : Model -> Model
login model =
    case model of
        Home { websocket, seed, config } ->
            case websocket of
                Just websocket ->
                    let
                        connection =
                            case getProbableConection model of
                                Just connection ->
                                    connection

                                Nothing ->
                                    Debug.crash
                                        "Trying to connect with invalid model."

                        -- Replace this line with Game.initialModel
                        -- when starting to integrate game with the
                        -- server
                        game =
                            Game.dummy
                                connection.id
                                connection.username
                                connection.token
                                config
                    in
                        Play
                            { game = game
                            , os = OS.initialModel
                            , websocket = websocket
                            , config = config
                            , seed = seed
                            }

                Nothing ->
                    model

        _ ->
            model


logout : Model -> Model
logout model =
    case model of
        Play { seed, config } ->
            initialModel seed config

        _ ->
            model


getConfig : Model -> Config
getConfig model =
    case model of
        Home m ->
            m.config

        Play m ->
            m.config



-- internals


getProbableConection : Model -> Maybe ProbableConnection
getProbableConection model =
    case model of
        Home model ->
            case model.connection of
                Just connection ->
                    Just connection

                Nothing ->
                    Nothing

        _ ->
            Nothing
