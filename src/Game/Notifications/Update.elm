module Game.Notifications.Update exposing (update)

import Dict
import Time exposing (Time)
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Notifications as Notifications
import Game.Notifications.Config exposing (..)
import Game.Notifications.Models exposing (..)
import Game.Notifications.Source exposing (..)
import Game.Notifications.Messages exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Source -> Msg -> Model -> UpdateResponse msg
update config source msg model =
    case msg of
        HandleReadAll ->
            handleReadAll model

        HandleInsert maybeTime content ->
            handleInsert config source maybeTime content model


handleReadAll : Model -> UpdateResponse msg
handleReadAll model =
    model
        |> Dict.map (\k v -> { v | isRead = True })
        |> Update.fromModel


handleInsert :
    Config msg
    -> Source
    -> Maybe Time
    -> Content
    -> Model
    -> UpdateResponse msg
handleInsert config source maybeTime content model =
    let
        time =
            case maybeTime of
                Just time ->
                    time

                Nothing ->
                    config.lastTick

        model_ =
            insert time (Notification content False) model

        dispatch =
            Dispatch.notifications <|
                Notifications.Toast (Just source) content
    in
        ( model_, Cmd.none, dispatch )
