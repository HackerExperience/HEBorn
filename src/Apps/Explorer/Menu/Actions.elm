module Apps.Explorer.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Messages as Filesystem exposing (Msg(..))
import Apps.Explorer.Models exposing (..)
import Apps.Explorer.Messages as Explorer exposing (Msg)
import Apps.Explorer.Menu.Messages as Menu exposing (MenuAction)


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd Explorer.Msg, Dispatch )
actionHandler data action ({ app } as model) =
    case action of
        Menu.Delete fileID ->
            let
                gameMsg =
                    Dispatch.filesystem
                        data.id
                        (Filesystem.Delete fileID)
            in
                ( model, Cmd.none, gameMsg )

        Menu.GoPath newPathId ->
            let
                fs =
                    Servers.getFilesystem data.server

                newPath =
                    newPathId
                        |> Filesystem.getFileById fs
                        |> Filesystem.getAbsolutePath

                newApp =
                    changePath
                        newPath
                        fs
                        app
            in
                ( { model | app = newApp }, Cmd.none, Dispatch.none )

        Menu.UpdateEditing newState ->
            let
                newApp =
                    setEditing
                        newState
                        app
            in
                ( { model | app = newApp }, Cmd.none, Dispatch.none )

        Menu.EnterRename fileId ->
            let
                fs =
                    Servers.getFilesystem data.server

                nowName =
                    fileId
                        |> Filesystem.getFileById fs
                        |> Filesystem.getFileName

                newApp =
                    setEditing
                        (Renaming fileId nowName)
                        app
            in
                ( { model | app = newApp }, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )
