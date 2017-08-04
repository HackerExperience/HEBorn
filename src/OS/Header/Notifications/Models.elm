module OS.Header.Notifications.Models
    exposing
        ( Model
        , AccountNotifications
        , ChatNotifications
        , GameNotifications
        , initialModel
        , remove
        , clean
        , notifyAccount
        , notifyChat
        , notifyGame
        , cleanAccount
        , cleanChat
        , cleanGame
        , listAccount
        , listChat
        , listGame
        )

import Dict as Dict exposing (Dict)
import Random.Pcg as Random
import Utils.Model.RandomUuid as RandomUuid
import OS.Header.Notifications.Types exposing (..)


-- TODO: add notification data


type alias Model =
    RandomUuid.Model
        { account : AccountNotifications
        , game : GameNotifications
        , chat : ChatNotifications
        }


type alias AccountNotifications =
    Dict ID Account


type alias GameNotifications =
    Dict ID Game


type alias ChatNotifications =
    Dict UserName Chat


initialModel : Model
initialModel =
    -- We may or not need to cast Cmd from here
    { account = Dict.empty
    , game = Dict.empty
    , chat = Dict.empty
    , randomUuidSeed = Random.initialSeed 465346887884
    }


remove : ID -> Model -> Model
remove id ({ account, chat, game } as model) =
    let
        account_ =
            Dict.remove id account

        chat_ =
            Dict.remove id chat

        game_ =
            Dict.remove id game

        model_ =
            { model
                | account = account_
                , chat = chat_
                , game = game_
            }
    in
        model_


clean : Model -> Model
clean model =
    let
        model_ =
            { model
                | account = Dict.empty
                , chat = Dict.empty
                , game = Dict.empty
            }
    in
        model_


notifyAccount : Content -> Model -> Model
notifyAccount content ({ account } as model0) =
    let
        ( model, uuid ) =
            RandomUuid.newUuid model0

        notification =
            { content = content }

        account_ =
            Dict.insert uuid notification account

        model_ =
            { model | account = account_ }
    in
        model_


notifyChat : Content -> Model -> Model
notifyChat content ({ chat } as model0) =
    let
        ( model, uuid ) =
            RandomUuid.newUuid model0

        notification =
            { content = content }

        chat_ =
            Dict.insert uuid notification chat

        model_ =
            { model | chat = chat_ }
    in
        model_


notifyGame : Maybe Origin -> Content -> Model -> Model
notifyGame maybeOrigin content ({ game } as model0) =
    let
        ( model, uuid ) =
            RandomUuid.newUuid model0

        notification =
            { origin = maybeOrigin
            , content = content
            }

        game_ =
            Dict.insert uuid notification game

        model_ =
            { model | game = game_ }
    in
        model_


cleanAccount : Model -> Model
cleanAccount model =
    let
        model_ =
            { model | account = Dict.empty }
    in
        model_


cleanChat : Model -> Model
cleanChat model =
    let
        model_ =
            { model | chat = Dict.empty }
    in
        model_


cleanGame : Model -> Model
cleanGame model =
    let
        model_ =
            { model | game = Dict.empty }
    in
        model_


listAccount : Model -> List ( ID, Account )
listAccount { account } =
    -- TODO: sort by date
    Dict.toList account


listChat : Model -> List ( UserName, Chat )
listChat { chat } =
    -- TODO: sort by date
    Dict.toList chat


listGame : Model -> List ( ID, Game )
listGame { game } =
    -- TODO: sort by date
    Dict.toList game
