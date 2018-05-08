module Apps.Explorer.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Shared as Filesystem
import Apps.Explorer.Config exposing (..)
import Apps.Explorer.Models exposing (..)
import Apps.Explorer.Messages exposing (Msg(..))


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update ({ activeServer } as config) msg model =
    let
        activeServerData =
            Tuple.second activeServer

        maybeFs =
            model
                |> getStorage activeServerData
                |> flip Servers.getStorage activeServerData
                |> Maybe.map Servers.getFilesystem
    in
        case maybeFs of
            Just fs ->
                realUpdate config fs msg model

            Nothing ->
                ( model, React.none )


realUpdate : Config msg -> Filesystem.Model -> Msg -> Model -> UpdateResponse msg
realUpdate config fs msg model =
    case msg of
        GoPath newPath ->
            onGoPath config newPath fs model

        GoStorage newStorageId ->
            onGoStorage newStorageId model

        UpdateEditing newState ->
            onUpdateEditing newState model

        EnterRename id ->
            onEnterRename config id fs model

        ApplyEdit ->
            onApplyEdit config fs model

        EnterModal modal ->
            ( { model | modal = modal }, React.none )

        _ ->
            -- TODO: implement folder operation requests
            ( model, React.none )


onGoPath :
    Config msg
    -> Filesystem.Path
    -> Filesystem.Model
    -> Model
    -> UpdateResponse msg
onGoPath config newPath fs model =
    let
        model_ =
            changePath newPath fs model
    in
        ( model_, React.none )


onGoStorage : String -> Model -> UpdateResponse msg
onGoStorage newStorageId model =
    let
        model_ =
            { model | storageId = Just newStorageId, path = [ "" ] }
    in
        ( model_, React.none )


onUpdateEditing : EditingStatus -> Model -> UpdateResponse msg
onUpdateEditing newState model =
    let
        model_ =
            setEditing newState model
    in
        ( model_, React.none )


onEnterRename :
    Config msg
    -> Filesystem.Id
    -> Filesystem.Model
    -> Model
    -> UpdateResponse msg
onEnterRename config id fs model =
    let
        file =
            Filesystem.getFile id fs

        editing_ =
            file
                |> Maybe.map
                    (Filesystem.getName >> Renaming id)
                |> Maybe.withDefault NotEditing

        model_ =
            setEditing editing_ model
    in
        ( model_, React.none )


onApplyEdit : Config msg -> Filesystem.Model -> Model -> UpdateResponse msg
onApplyEdit config fs model =
    let
        { onNewTextFile, onNewDir, onMoveFile, onRenameFile } =
            config

        storageId =
            getStorage (Tuple.second config.activeServer) model

        react =
            case model.editing of
                NotEditing ->
                    React.none

                CreatingFile fName ->
                    if Filesystem.isValidFilename fName then
                        React.none
                    else
                        React.msg <| onNewTextFile model.path fName storageId

                CreatingPath fName ->
                    if Filesystem.isValidFilename fName then
                        React.none
                    else
                        React.msg <| onNewDir model.path fName storageId

                Moving fID ->
                    React.msg <| onMoveFile fID model.path storageId

                Renaming fID fName ->
                    if Filesystem.isValidFilename fName then
                        React.none
                    else
                        React.msg <| onRenameFile fID fName storageId

                _ ->
                    -- TODO: implement folder operation requests
                    React.none

        model_ =
            setEditing NotEditing model
    in
        ( model_, react )
