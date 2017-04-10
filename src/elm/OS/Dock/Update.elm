module OS.Dock.Update exposing (update)

import Core.Messages exposing (CoreMsg)
import OS.Messages exposing (OSMsg)
import OS.Dock.Models exposing (Model)
import OS.Dock.Messages exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd OSMsg, List CoreMsg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none, [] )
