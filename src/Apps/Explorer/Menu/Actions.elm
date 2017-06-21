module Apps.Explorer.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Game.Servers.Filesystem.Messages as Filesystem exposing (Msg(..))
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages as Explorer exposing (Msg)
import Apps.Explorer.Menu.Messages exposing (MenuAction(..))


actionHandler :
    MenuAction
    -> Model
    -> Game.Model
    -> ( Model, Cmd Explorer.Msg, Dispatch )
actionHandler action model game =
    case action of
        DeleteFile fileID ->
            let
                gameMsg =
                    Dispatch.filesystem
                        "localhost"
                        (Filesystem.Delete fileID)
            in
                ( model, Cmd.none, gameMsg )

        Dummy ->
            ( model, Cmd.none, Dispatch.none )
