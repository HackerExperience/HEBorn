module Apps.Explorer.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Models as Filesystem
import Apps.Explorer.Models exposing (..)
import Apps.Explorer.Messages exposing (..)
import Apps.Explorer.Menu.Messages as Menu exposing (MenuAction)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


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
            fileId
                |> Servers.DeleteFile
                |> Dispatch.filesystem (Game.getActiveCId data)
    in
        ( model, Cmd.none, gameMsg )


onGoPath :
    Game.Data
    -> String
    -> Model
    -> UpdateResponse
onGoPath data pathId model =
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
                                    model
                           )
                    )
                |> Maybe.withDefault model
    in
        ( model_, Cmd.none, Dispatch.none )


onUpdateEditing :
    EditingStatus
    -> Model
    -> UpdateResponse
onUpdateEditing state_ model =
    let
        model_ =
            setEditing
                state_
                model
    in
        ( model_, Cmd.none, Dispatch.none )


onEnterRename :
    Game.Data
    -> String
    -> Model
    -> UpdateResponse
onEnterRename data fileId model =
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
                        >> ((flip setEditing) model)
                    )
                |> Maybe.withDefault model
    in
        ( model_, Cmd.none, Dispatch.none )
