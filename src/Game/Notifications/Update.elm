module Game.Notifications.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Notifications.Models exposing (..)
import Game.Notifications.Messages exposing (..)


update : Game.Data -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update data msg model =
    case msg of
        Todo ->
            Update.fromModel model
