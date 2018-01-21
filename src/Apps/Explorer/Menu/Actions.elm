module Apps.Explorer.Menu.Actions exposing (actionHandler)

import Utils.React as React exposing (React)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Shared as Filesystem
import Apps.Explorer.Config exposing (..)
import Apps.Explorer.Models exposing (..)
import Apps.Explorer.Messages exposing (..)
import Apps.Explorer.Menu.Messages as Menu exposing (MenuAction)


type alias UpdateResponse msg =
    ( Model, React msg )


actionHandler :
    Config msg
    -> MenuAction
    -> Model
    -> UpdateResponse msg
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
            ( model, React.none )


onDelete :
    Config msg
    -> String
    -> Model
    -> UpdateResponse msg
onDelete config id model =
    let
        storage =
            getStorage config.activeServer model

        --gameMsg =
        --    id
        --        |> Servers.DeleteFile
        --        |> Dispatch.filesystem config.activeCId storage
    in
        ( model, React.none )


onGoPath :
    Config msg
    -> Filesystem.Path
    -> Model
    -> UpdateResponse msg
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
                    ( changePath path fs model, React.none )
                else
                    ( model, React.none )

            Nothing ->
                ( model, React.none )


onUpdateEditing :
    EditingStatus
    -> Model
    -> UpdateResponse msg
onUpdateEditing state_ model =
    ( setEditing state_ model, React.none )


onEnterRename :
    Config msg
    -> Filesystem.Id
    -> Model
    -> UpdateResponse msg
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
                            ( model, React.none )

                    Nothing ->
                        ( model, React.none )

            Nothing ->
                ( model, React.none )
