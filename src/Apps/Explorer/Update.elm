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
    case msg of
        -- Menu
        MenuMsg (Menu.MenuClick action) ->
            actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model

        -- General Acts
        GoPath newPath ->
            onGoPath data newPath model

        UpdateEditing newState ->
            onUpdateEditing newState model

        EnterRename fileId ->
            onEnterRename data fileId model

        ApplyEdit ->
            onApplyEdit data model


onMenuMsg : Game.Data -> Menu.Msg -> Model -> UpdateResponse
onMenuMsg data msg model =
    let
        ( menu_, cmd, coreMsg ) =
            Menu.update data msg model.menu

        cmd_ =
            Cmd.map MenuMsg cmd
    in
        ( { model | menu = menu_ }, cmd_, coreMsg )


onGoPath : Game.Data -> Filesystem.Location -> Model -> UpdateResponse
onGoPath data newPath model =
    let
        fs =
            (Servers.getFilesystem <| Game.getActiveServer <| data)

        model_ =
            changePath newPath fs model
    in
        Update.fromModel model_


onUpdateEditing : EditingStatus -> Model -> UpdateResponse
onUpdateEditing newState model =
    let
        model_ =
            setEditing newState model
    in
        Update.fromModel model_


onEnterRename : Game.Data -> String -> Model -> UpdateResponse
onEnterRename data fileId model =
    let
        fs =
            data
                |> Game.getActiveServer
                |> Servers.getFilesystem

        file =
            Filesystem.getEntry fileId fs

        editing_ =
            file
                |> Maybe.map
                    (Filesystem.getEntryBasename >> Renaming fileId)
                |> Maybe.withDefault NotEditing

        model_ =
            setEditing editing_ model
    in
        Update.fromModel model_


onApplyEdit : Game.Data -> Model -> UpdateResponse
onApplyEdit data model =
    let
        fsMsg =
            data
                |> Game.getActiveCId
                |> Dispatch.filesystem

        gameMsg =
            case model.editing of
                NotEditing ->
                    Dispatch.none

                CreatingFile fName ->
                    if Filesystem.isValidFilename fName then
                        Dispatch.none
                    else
                        fsMsg <| Servers.NewTextFile ( model.path, fName )

                CreatingPath fName ->
                    if Filesystem.isValidFilename fName then
                        Dispatch.none
                    else
                        fsMsg <| Servers.NewDir ( model.path, fName )

                Moving fID ->
                    fsMsg <| Servers.MoveFile fID model.path

                Renaming fID fName ->
                    if Filesystem.isValidFilename fName then
                        Dispatch.none
                    else
                        fsMsg <| Servers.RenameFile fID fName

        model_ =
            setEditing NotEditing model
    in
        ( model_, Cmd.none, gameMsg )
