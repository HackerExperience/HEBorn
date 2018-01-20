module Apps.Explorer.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Shared as Filesystem
import Apps.Explorer.Models exposing (..)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Menu.Messages as Menu
import Apps.Explorer.Menu.Update as Menu
import Apps.Explorer.Menu.Actions exposing (actionHandler)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Data -> Msg -> Model -> UpdateResponse
update data msg model =
    let
        server =
            Game.getActiveServer data

        maybeFs =
            model
                |> getStorage server
                |> flip Servers.getStorage server
                |> Maybe.map Servers.getFilesystem
    in
        case maybeFs of
            Just fs ->
                case msg of
                    -- Menu
                    MenuMsg (Menu.MenuClick action) ->
                        actionHandler data action model

                    MenuMsg msg ->
                        onMenuMsg data msg model

                    -- General Acts
                    GoPath newPath ->
                        onGoPath data newPath fs model

                    GoStorage newStorageId ->
                        onGoStorage newStorageId model

                    UpdateEditing newState ->
                        onUpdateEditing newState model

                    EnterRename id ->
                        onEnterRename data id fs model

                    ApplyEdit ->
                        onApplyEdit data fs model

                    _ ->
                        -- TODO: implement folder operation requests
                        Update.fromModel model

            Nothing ->
                Update.fromModel model


onMenuMsg : Game.Data -> Menu.Msg -> Model -> UpdateResponse
onMenuMsg data msg model =
    let
        ( menu_, cmd, coreMsg ) =
            Menu.update data msg model.menu

        cmd_ =
            Cmd.map MenuMsg cmd

        model_ =
            { model | menu = menu_ }
    in
        ( model_, cmd_, coreMsg )


onGoPath :
    Game.Data
    -> Filesystem.Path
    -> Filesystem.Model
    -> Model
    -> UpdateResponse
onGoPath data newPath fs model =
    Update.fromModel <| changePath newPath fs model


onGoStorage : String -> Model -> UpdateResponse
onGoStorage newStorageId model =
    { model | storageId = Just newStorageId, path = [ "" ] }
        |> Update.fromModel


onUpdateEditing : EditingStatus -> Model -> UpdateResponse
onUpdateEditing newState model =
    let
        model_ =
            setEditing newState model
    in
        Update.fromModel model_


onEnterRename :
    Game.Data
    -> Filesystem.Id
    -> Filesystem.Model
    -> Model
    -> UpdateResponse
onEnterRename data id fs model =
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
        Update.fromModel model_


onApplyEdit : Game.Data -> Filesystem.Model -> Model -> UpdateResponse
onApplyEdit data fs model =
    let
        storageId =
            getStorage (Game.getActiveServer data) model

        fsMsg =
            Dispatch.filesystem (Game.getActiveCId data) storageId

        gameMsg =
            case model.editing of
                NotEditing ->
                    Dispatch.none

                CreatingFile fName ->
                    if Filesystem.isValidFilename fName then
                        Dispatch.none
                    else
                        fsMsg <| Servers.NewTextFile model.path fName

                CreatingPath fName ->
                    if Filesystem.isValidFilename fName then
                        Dispatch.none
                    else
                        fsMsg <| Servers.NewDir model.path fName

                Moving fID ->
                    fsMsg <| Servers.MoveFile fID model.path

                Renaming fID fName ->
                    if Filesystem.isValidFilename fName then
                        Dispatch.none
                    else
                        fsMsg <| Servers.RenameFile fID fName

                _ ->
                    -- TODO: implement folder operation requests
                    Dispatch.none

        model_ =
            setEditing NotEditing model
    in
        ( model_, Cmd.none, gameMsg )
