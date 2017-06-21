module Apps.Explorer.Menu.Actions exposing (actionHandler)

import Core.Messages as Core
import Core.Dispatcher exposing (callFilesystem)
import Game.Models as Game
import Game.Servers.Filesystem.Messages as Filesystem exposing (Msg(..))
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages as Explorer exposing (Msg)
import Apps.Explorer.Menu.Messages exposing (ActionMsg(..))


actionHandler :
    ActionMsg
    -> Model
    -> Game.Model
    -> ( Model, Cmd Explorer.Msg, List Core.Msg )
actionHandler action model game =
    case action of
        DeleteFile fileID ->
            let
                gameMsg =
                    callFilesystem
                        "localhost"
                        (Filesystem.Delete fileID)
            in
                ( model, Cmd.none, [ gameMsg ] )

        Dummy ->
            ( model, Cmd.none, [] )
