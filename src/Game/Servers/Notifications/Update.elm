module Game.Servers.Notifications.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Meta.Types.Notifications exposing (..)
import Game.Servers.Notifications.Config exposing (..)
import Game.Servers.Notifications.Messages exposing (..)
import Game.Servers.Notifications.Models exposing (..)
import Game.Servers.Notifications.Shared exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> ( Model, React msg )
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

        HandleUploadStarted nip storage entry ->
            handleNewNotification
                config
                (UploadStarted nip storage entry)
                model

        HandleUploadConcluded nip storage entry ->
            handleNewNotification
                config
                (UploadConcluded nip storage entry)
                model

        HandleBruteforceStarted nip ->
            handleNewNotification
                config
                (BruteforceStarted nip)
                model

        HandleBruteforceConcluded nip ->
            handleNewNotification
                config
                (BruteforceConcluded nip)
                model

        HandleGeneric title content ->
            handleNewNotification config (Generic title content) model

        HandleReadAll ->
            ( readAll model, React.none )


{-| Cria uma nova notificação.
-}
handleNewNotification :
    Config msg
    -> Content
    -> Model
    -> UpdateResponse msg
handleNewNotification config content model =
    ( insert config.lastTick (Notification content False) model
    , React.msg <| config.onToast content
    )
