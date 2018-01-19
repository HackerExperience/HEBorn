module Apps.Explorer.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Shared as Filesystem
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
        Menu.Delete id ->
            onDelete data id model

        Menu.GoPath path ->
            onGoPath data path model

        Menu.UpdateEditing state ->
            onUpdateEditing state model

        Menu.EnterRename id ->
            onEnterRename data id model

        _ ->
            ( model, Cmd.none, Dispatch.none )


onDelete :
    Game.Data
    -> String
    -> Model
    -> UpdateResponse
onDelete data id model =
    let
        storage =
            getStorage (Game.getActiveServer data) model

        gameMsg =
            id
                |> Servers.DeleteFile
                |> Dispatch.filesystem (Game.getActiveCId data) storage
    in
        ( model, Cmd.none, gameMsg )


onGoPath :
    Game.Data
    -> Filesystem.Path
    -> Model
    -> UpdateResponse
onGoPath data path model =
    let
        server =
            Game.getActiveServer data

        storage =
            getStorage server model

        maybeFs =
            server
                |> Servers.getStorage storage
                |> Maybe.map Servers.getFilesystem
    in
        case maybeFs of
            Just fs ->
                if Filesystem.isFolder path fs then
                    ( changePath path fs model
                    , Cmd.none
                    , Dispatch.none
                    )
                else
                    ( model, Cmd.none, Dispatch.none )

            Nothing ->
                ( model, Cmd.none, Dispatch.none )


onUpdateEditing :
    EditingStatus
    -> Model
    -> UpdateResponse
onUpdateEditing state_ model =
    ( setEditing state_ model, Cmd.none, Dispatch.none )


onEnterRename :
    Game.Data
    -> Filesystem.Id
    -> Model
    -> UpdateResponse
onEnterRename data id model =
    let
        server =
            Game.getActiveServer data

        storage =
            getStorage server model

        maybeFs =
            server
                |> Servers.getStorage storage
                |> Maybe.map Servers.getFilesystem
    in
        case maybeFs of
            Just fs ->
                case Filesystem.getFile id fs of
                    Just file ->
                        let
                            model_ =
                                file
                                    |> Filesystem.getName
                                    |> Renaming id
                                    |> ((flip setEditing) model)
                        in
                            ( model, Cmd.none, Dispatch.none )

                    Nothing ->
                        ( model, Cmd.none, Dispatch.none )

            Nothing ->
                ( model, Cmd.none, Dispatch.none )
