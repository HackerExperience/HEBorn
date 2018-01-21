module Apps.Explorer.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Shared as Filesystem
import Apps.Explorer.Config exposing (..)
import Apps.Explorer.Models exposing (..)
import Apps.Explorer.Messages exposing (..)
import Apps.Explorer.Menu.Messages as Menu exposing (MenuAction)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


actionHandler :
    Config msg
    -> MenuAction
    -> Model
    -> UpdateResponse
actionHandler config action model =
    case action of
        Menu.Delete id ->
            onDelete config id model

        Menu.GoPath path ->
            onGoPath config path model

        Menu.UpdateEditing state ->
            onUpdateEditing state model

        Menu.EnterRename id ->
            onEnterRename config id model

        _ ->
            ( model, Cmd.none, Dispatch.none )


onDelete :
    Config msg
    -> String
    -> Model
    -> UpdateResponse
onDelete config id model =
    let
        storage =
            getStorage config.activeServer model

        --gameMsg =
        --    id
        --        |> Servers.DeleteFile
        --        |> Dispatch.filesystem config.activeCId storage
    in
        ( model, Cmd.none, Dispatch.none )


onGoPath :
    Config msg
    -> Filesystem.Path
    -> Model
    -> UpdateResponse
onGoPath config path model =
    let
        server =
            config.activeServer

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
    Config msg
    -> Filesystem.Id
    -> Model
    -> UpdateResponse
onEnterRename config id model =
    let
        server =
            config.activeServer

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
