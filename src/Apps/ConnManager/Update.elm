module Apps.ConnManager.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Utils.Update as Update
import Apps.ConnManager.Models exposing (Model)
import Apps.ConnManager.Messages as ConnManager exposing (Msg(..))


type alias UpdateResponse =
    ( Model, Cmd ConnManager.Msg, Dispatch )


update :
    Game.Data
    -> ConnManager.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        -- TODO: Filter
        _ ->
            Update.fromModel model
