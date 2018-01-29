module Core.Models
    exposing
        ( Model
        , State(..)
        , HomeModel
        , SetupModel
        , PlayModel
        , init
        , initialModel
        , getFlags
        , connect
        , login
        , logout
        , crash
        , setupToPlay
        )

import ContextMenu exposing (ContextMenu)
import Core.Flags as Flags exposing (Flags)
import Core.Messages exposing (..)
import Driver.Websocket.Launch as Ws
import Driver.Websocket.Models as Ws
import Landing.Models as Landing
import Setup.Models as Setup
import Game.Models as Game
import Game.Account.Models as Account
import Game.Dummy as Game
import OS.Models as OS


type alias Model =
    { state : State
    , flags : Flags
    , seed : Int
    , windowLoaded : Bool
    , contextMenu : ContextMenuShit
    }


type State
    = Home HomeModel
    | Setup SetupModel
    | Play PlayModel
    | Panic String String


type alias HomeModel =
    { landing : Landing.Model
    , websocket : Maybe (Ws.Model Msg)
    , connecting : Maybe Connecting
    }


type alias SetupModel =
    { websocket : Ws.Model Msg
    , game : Game.Model
    , setup : Setup.Model
    }


type alias PlayModel =
    { websocket : Ws.Model Msg
    , game : Game.Model
    , os : OS.Model
    }


type alias Connecting =
    { id : Account.ID
    , username : Account.Username
    , token : Account.Token
    }


type alias ContextMenuShit =
    ContextMenu (List (List ( ContextMenu.Item, Msg )))


init : Int -> Flags -> ( Model, Cmd Msg )
init seed flags =
    let
        ( menuModel, menuCmd ) =
            ContextMenu.init

        model =
            { state = Home initialHome
            , flags = flags
            , seed = seed
            , windowLoaded = False
            , contextMenu = menuModel
            }

        cmd =
            Cmd.map MenuMsg menuCmd
    in
        ( model, cmd )


initialModel : Int -> Flags -> Model
initialModel seed flags =
    flags
        |> init seed
        |> Tuple.first


connect : Account.ID -> Account.Username -> Account.Token -> Model -> Model
connect id username token ({ state, flags } as model) =
    case state of
        Home home ->
            let
                connecting =
                    Just <| Connecting id username token

                websocket =
                    Just <| Ws.launch WebsocketMsg flags.apiWsUrl token "web1"

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


login : Model -> ( Model, Cmd Msg )
login ({ state, flags } as model) =
    case state of
        Home ({ connecting, websocket } as home) ->
            case connecting of
                Just ({ token } as connecting) ->
                    -- TODO: add setup check here
                    let
                        websocket_ =
                            Maybe.withDefault
                                (Ws.launch WebsocketMsg
                                    flags.apiWsUrl
                                    token
                                    "web1"
                                )
                                websocket

                        game =
                            initialGame connecting flags

                        ( state_, cmd ) =
                            initialSetup websocket_ game

                        model_ =
                            { model | state = Setup state_ }
                    in
                        ( model_, cmd )

                Nothing ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


logout : Model -> Model
logout model =
    { model | state = Home initialHome }


crash : String -> String -> Model -> Model
crash code message model =
    { model | state = Panic code message }


getFlags : Model -> Flags
getFlags =
    .flags


setupToPlay : State -> ( State, Cmd Msg )
setupToPlay state =
    case state of
        Setup { websocket, game } ->
            let
                ( play, cmd ) =
                    initialPlay websocket game

                state_ =
                    Play play
            in
                ( state_, cmd )

        _ ->
            ( state, Cmd.none )



-- internals


initialHome : HomeModel
initialHome =
    { websocket = Nothing
    , landing = Landing.initialModel
    , connecting = Nothing
    }


initialSetup : Ws.Model Msg -> Game.Model -> ( SetupModel, Cmd Msg )
initialSetup ws game =
    ( { websocket = ws
      , game = game
      , setup = Setup.initialModel
      }
    , Cmd.none
    )


initialPlay : Ws.Model Msg -> Game.Model -> ( PlayModel, Cmd Msg )
initialPlay ws game =
    let
        play_ =
            { websocket = ws
            , game = game
            , os = OS.initialModel
            }
    in
        ( play_, Cmd.none )


initialGame : Connecting -> Flags -> Game.Model
initialGame { id, username, token } flags =
    Game.dummy id username token flags
