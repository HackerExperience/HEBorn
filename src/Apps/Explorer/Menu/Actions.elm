module Apps.Explorer.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Messages as Filesystem
import Apps.Explorer.Models exposing (..)
import Apps.Explorer.Messages as Explorer exposing (Msg)
import Apps.Explorer.Menu.Messages as Menu exposing (MenuAction)


type alias UpdateResponse =
    ( Model, Cmd Explorer.Msg, Dispatch )


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> UpdateResponse
actionHandler data action model =
    case action of
        Menu.Delete fileId ->
            onDelete data fileId model

        Menu.GoPath newPathId ->
            onGoPath data newPathId model

        Menu.UpdateEditing newState ->
            onUpdateEditing newState model

        Menu.EnterRename fileId ->
            onEnterRename data fileId model

        _ ->
            ( model, Cmd.none, Dispatch.none )


onDelete :
    Game.Data
    -> String
    -> Model
    -> UpdateResponse
onDelete data fileId model =
    let
        gameMsg =
            Dispatch.filesystem
                (Game.getActiveCId data)
                (Filesystem.Delete fileId)
    in
        ( model, Cmd.none, gameMsg )


onGoPath :
    Game.Data
    -> String
    -> Model
    -> UpdateResponse
onGoPath data pathId ({ app } as model) =
    let
        fs =
            data
                |> Game.getActiveServer
                |> Servers.getFilesystem

        getEntry =
            (flip Filesystem.getEntry) fs

        getEntryLink =
            (flip Filesystem.getEntryLink) fs

        model_ =
            pathId
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


onUpdateEditing :
    EditingStatus
    -> Model
    -> UpdateResponse
onUpdateEditing state_ ({ app } as model) =
    let
        newApp =
            setEditing
                state_
                app

        model_ =
            { model | app = newApp }
    in
        ( model_, Cmd.none, Dispatch.none )


onEnterRename :
    Game.Data
    -> String
    -> Model
    -> UpdateResponse
onEnterRename data fileId ({ app } as model) =
    let
        fs =
            data
                |> Game.getActiveServer
                |> Servers.getFilesystem

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
