module Game.Account.Notifications.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Meta.Types.Notifications exposing (..)
import Game.Account.Notifications.Config exposing (..)
import Game.Account.Notifications.Messages exposing (..)
import Game.Account.Notifications.Models exposing (..)
import Game.Account.Notifications.Shared exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandleNewEmail personId ->
            handleNewNotification config (NewEmail personId) model

        HandleGeneric title content ->
            handleNewNotification config (Generic title content) model

        HandleReadAll ->
            ( readAll model, React.none )


handleNewNotification :
    Config msg
    -> Content
    -> Model
    -> ( Model, React msg )
handleNewNotification config content model =
    ( insert config.lastTick (Notification content False) model
    , React.msg <| config.onToast content
    )
