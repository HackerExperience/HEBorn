module Apps.Explorer.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Servers.Filesystem.Messages as Filesystem exposing (Msg(..))
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages as Explorer exposing (Msg)
import Apps.Explorer.Menu.Messages as Menu exposing (MenuAction)


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd Explorer.Msg, Dispatch )
actionHandler data action model =
    case action of
        Menu.Delete fileID ->
            let
                gameMsg =
                    Dispatch.filesystem
                        data.id
                        (Filesystem.Delete fileID)
            in
                ( model, Cmd.none, gameMsg )

        _ ->
            ( model, Cmd.none, Dispatch.none )
