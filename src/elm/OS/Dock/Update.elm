module OS.Dock.Update exposing (update)

import Core.Messages exposing (CoreMsg)
import OS.Messages exposing (OSMsg)
import OS.Dock.Models exposing (Model, updateInstances)
import OS.Dock.Messages exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd OSMsg, List CoreMsg )
update msg model =
    case msg of
        WindowsChanges windows ->
            ( (updateInstances model windows), Cmd.none, [] )

        _ ->
            ( model, Cmd.none, [] )
