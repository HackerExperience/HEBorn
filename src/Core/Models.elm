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
        )

import Driver.Websocket.Models as Ws
import Game.Models as Game
import Game.Account.Models as Account
import Game.Dummy as Game
import OS.Models as OS
import Landing.Models as Landing
import Core.Config as Config exposing (Config)


type alias Model =
    { state : State
    , config : Config
    , seed : Int
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
    , connecting : Connecting
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
    }


initialModel : Int -> Config -> Model
initialModel seed config =
    { state = Home initialHome
    , config = config
    , seed = seed
    }


connect : Account.ID -> Account.Username -> Account.Token -> Model -> Model
connect id username token ({ state, config } as model) =
    case state of
        Home home ->
            let
                connecting =
                    Just <| Connecting id username token

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


login : Model -> Model
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

                        play =
                            initialPlay websocket_ connecting config

                        state_ =
                            Play play

                        model_ =
                            { model | state = state_ }
                    in
                        model_

                Nothing ->
                    model

        _ ->
            model


logout : Model -> Model
logout model =
    { model | state = Home initialHome }


getConfig : Model -> Config
getConfig =
    .config



-- internals


initialHome : HomeModel
initialHome =
    { websocket = Nothing
    , landing = Landing.initialModel
    , connecting = Nothing
    }


initialSetup : Ws.Model -> Connecting -> SetupModel
initialSetup ws connecting =
    { websocket = ws, connecting = connecting }


initialPlay : Ws.Model -> Connecting -> Config -> PlayModel
initialPlay ws { id, username, token } config =
    { websocket = ws
    , game = Game.dummy id username token config
    , os = OS.initialModel
    }
