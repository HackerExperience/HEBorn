module Game.Notifications.Update exposing (update)

import Dict
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Game.Notifications.Models exposing (..)
import Game.Notifications.Messages exposing (..)


update : Game.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update data msg model =
    case msg of
        ReadAll ->
            -- TODO: Add request to server
            model
                |> Dict.map
                    (\k v -> { v | isRead = True })
                |> Update.fromModel
