module Game.Servers.Notifications.Update exposing (update)

import Game.Meta.Types.Notifications exposing (..)
import Game.Servers.Notifications.Config exposing (..)
import Game.Servers.Notifications.Messages exposing (..)
import Game.Servers.Notifications.Models exposing (..)
import Game.Servers.Notifications.Shared exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg )


update : Config msg -> Msg -> Model -> ( Model, Cmd msg )
update config msg model =
    case msg of
        HandleDownloadStarted nip storage entry ->
            handleNewNotification
                config
                (DownloadStarted nip storage entry)
                model

        HandleDownloadConcluded nip storage entry ->
            handleNewNotification
                config
                (DownloadConcluded nip storage entry)
                model

        HandleGeneric title content ->
            handleNewNotification config (Generic title content) model

        HandleReadAll ->
            ( readAll model, Cmd.none )


handleNewNotification :
    Config msg
    -> Content
    -> Model
    -> ( Model, Cmd msg )
handleNewNotification config content model =
    let
        model_ =
            insert config.lastTick (Notification content False) model

        --dispatch =
        --    Dispatch.notifications <|
        --        Notifications.Toast (Just source) content
    in
        ( model_, Cmd.none )
