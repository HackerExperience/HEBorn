module Apps.Explorer.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Messages as Filesystem
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

                getEntry =
                    (flip Filesystem.getEntry) fs

                getEntryLink =
                    (flip Filesystem.getEntryLink) fs

                model_ =
                    newPathId
                        |> getEntry
                        |> Maybe.map
                            (getEntryLink
                                >> (\( loc, last ) ->
                                        changePath
                                            (loc ++ [ last ])
                                            fs
                                            app
                                   )
                                >> (\newApp -> { model | app = newApp })
                            )
                        |> Maybe.withDefault model
            in
                ( model_, Cmd.none, Dispatch.none )

        Menu.UpdateEditing newState ->
            let
                newApp =
                    setEditing
                        newState
                        app

                model_ =
                    { model | app = newApp }
            in
                ( model_, Cmd.none, Dispatch.none )

        Menu.EnterRename fileId ->
            let
                fs =
                    Servers.getFilesystem data.server

                getEntry =
                    (flip Filesystem.getEntry) fs

                model_ =
                    fileId
                        |> getEntry
                        |> Maybe.map
                            (Filesystem.getEntryBasename
                                >> Renaming fileId
                                >> ((flip setEditing) app)
                                >> (\newApp -> { model | app = newApp })
                            )
                        |> Maybe.withDefault model
            in
                ( model_, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )
