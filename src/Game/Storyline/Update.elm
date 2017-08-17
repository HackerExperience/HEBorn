module Game.Storyline.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Models as Game
import Game.Storyline.Models exposing (..)
import Game.Storyline.Messages exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Toggle ->
            let
                model_ =
                    { model | enabled = (not model.enabled) }
            in
                Update.fromModel model_
