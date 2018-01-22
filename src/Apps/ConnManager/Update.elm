module Apps.ConnManager.Update exposing (update)

import Utils.React as React exposing (React)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Utils.Update as Update
import Apps.ConnManager.Config exposing (..)
import Apps.ConnManager.Models exposing (Model)
import Apps.ConnManager.Messages as ConnManager exposing (Msg(..))


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> ConnManager.Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        -- TODO: Filter
        _ ->
            ( model, React.none )
