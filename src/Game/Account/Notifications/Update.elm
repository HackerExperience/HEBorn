module Game.Account.Notifications.Update exposing (update)

import Game.Meta.Types.Notifications exposing (..)
import Game.Account.Notifications.Config exposing (..)
import Game.Account.Notifications.Messages exposing (..)
import Game.Account.Notifications.Models exposing (..)
import Game.Account.Notifications.Shared exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg )


update : Config msg -> Msg -> Model -> ( Model, Cmd msg )
update config msg model =
    case msg of
        HandleNewEmail personId ->
            handleNewNotification config (NewEmail personId) model

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
