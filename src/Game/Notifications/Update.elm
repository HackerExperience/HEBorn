module Game.Notifications.Update exposing (update)

import Dict
import Time exposing (Time)
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Notifications as Notifications
import Game.Models as Game
import Game.Notifications.Models exposing (..)
import Game.Notifications.Source exposing (..)
import Game.Notifications.Messages exposing (..)
import Game.Meta.Models as Meta


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Source -> Msg -> Model -> UpdateResponse
update game source msg model =
    case msg of
        HandleReadAll ->
            handleReadAll model

        HandleInsert maybeTime content ->
            handleInsert game source maybeTime content model


handleReadAll : Model -> UpdateResponse
handleReadAll model =
    model
        |> Dict.map (\k v -> { v | isRead = True })
        |> Update.fromModel


handleInsert :
    Game.Model
    -> Source
    -> Maybe Time
    -> Content
    -> Model
    -> UpdateResponse
handleInsert game source maybeTime content model =
    let
        time =
            case maybeTime of
                Just time ->
                    time

                Nothing ->
                    game
                        |> Game.getMeta
                        |> Meta.getLastTick

        model_ =
            insert time (Notification content False) model

        dispatch =
            Dispatch.notifications <|
                Notifications.Toast (Just source) content
    in
        ( model_, Cmd.none, dispatch )
