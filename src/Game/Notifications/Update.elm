module Game.Notifications.Update exposing (update)

import Dict
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Game.Notifications.Models exposing (..)
import Game.Notifications.Messages exposing (..)
import OS.Toasts.Messages as Toasts
import OS.Toasts.Models as Toasts


update : Game.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update data msg model =
    case msg of
        ReadAll ->
            -- TODO: Add request to server
            model
                |> Dict.map
                    (\k v -> { v | isRead = True })
                |> Update.fromModel

        Insert created notif ->
            let
                model_ =
                    insert created notif model

                dispatch_ =
                    Toasts.Toast
                        notif.content
                        Nothing
                        Toasts.Alive
                        |> Toasts.Append
                        |> Dispatch.toasts
            in
                ( model_, Cmd.none, dispatch_ )
