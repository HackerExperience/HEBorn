module OS.Dock.Update exposing (update)

import OS.Messages exposing (OSMsg)
import Game.Messages exposing (GameMsg)
import OS.Dock.Models exposing (Model)
import OS.Dock.Messages exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd OSMsg, List GameMsg, List OSMsg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none, [], [] )
