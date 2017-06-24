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

import Driver.Websocket.Models as Websocket
import Game.Models as Game
import OS.Models as OS
import Landing.Models as Landing
import Core.Config as Config exposing (Config)


type Model
    = Home HomeModel
    | Play PlayModel


type alias HomeModel =
    { landing : Landing.Model
    , websocket : Maybe Websocket.Model
    , config : Config
    , seed : Int
    }


type alias PlayModel =
    { game : Game.Model
    , os : OS.Model
    , websocket : Websocket.Model
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
        }


connect : String -> String -> Model -> Model
connect token id model =
    case model of
        Home model ->
            let
                websocket =
                    Just (Websocket.initialModel model.config.apiWsUrl token id)
            in
                Home { model | websocket = websocket }

        _ ->
            model


login : String -> Model -> Model
login token model =
    case model of
        Home { websocket, seed, config } ->
            case websocket of
                Just websocket ->
                    let
                        game =
                            Game.initialModel token config
                    in
                        Play
                            { game = game
                            , os = OS.initialModel game
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
