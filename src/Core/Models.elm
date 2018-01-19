module Core.Models
    exposing
        ( Model
        , State(..)
        , HomeModel
        , SetupModel
        , PlayModel
        , initialModel
        , getFlags
        , connect
        , login
        , logout
        , crash
        , setupToPlay
        )

import Driver.Websocket.Models as Ws
import Game.Models as Game
import Game.Account.Models as Account
import Game.Dummy as Game
import OS.Models as OS
import Utils.Update as Update
import Landing.Models as Landing
import Setup.Models as Setup
import Core.Flags as Flags exposing (Flags)
import Core.Messages exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias Model =
    { state : State
    , flags : Flags
    , seed : Int
    , windowLoaded : Bool
    }


type State
    = Home HomeModel
    | Setup SetupModel
    | Play PlayModel
    | Panic String String


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
    }


initialModel : Int -> Flags -> Model
initialModel seed flags =
    { state = Home initialHome
    , flags = flags
    , seed = seed
    , windowLoaded = False
    }


connect : Account.ID -> Account.Username -> Account.Token -> Model -> Model
connect id username token ({ state, flags } as model) =
    case state of
        Home home ->
            let
                connecting =
                    Just <| Connecting id username token

                websocket =
                    Just <| Ws.initialModel flags.apiWsUrl token "web1"

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
login ({ state, flags } as model) =
    case state of
        Home ({ connecting, websocket } as home) ->
            case connecting of
                Just ({ token } as connecting) ->
                    -- TODO: add setup check here
                    let
                        websocket_ =
                            Maybe.withDefault
                                (Ws.initialModel flags.apiWsUrl token "web1")
                                websocket

                        game =
                            initialGame connecting flags

                        ( state_, cmd, dispatch ) =
                            initialSetup websocket_ game
                                |> Update.mapModel Setup

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


crash : String -> String -> Model -> Model
crash code message model =
    { model | state = Panic code message }


getFlags : Model -> Flags
getFlags =
    .flags


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


initialGame : Connecting -> Flags -> Game.Model
initialGame { id, username, token } flags =
    Game.dummy id username token flags
