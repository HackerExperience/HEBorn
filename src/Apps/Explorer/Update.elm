module Apps.Explorer.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Filesystem.Messages as Filesystem
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
onGoPath data newPath ({ app } as model) =
    let
        fs =
            (Servers.getFilesystem <| Game.getActiveServer <| data)

        app_ =
            changePath
                newPath
                fs
                app
    in
        Update.fromModel { model | app = app_ }


onUpdateEditing : EditingStatus -> Model -> UpdateResponse
onUpdateEditing newState ({ app } as model) =
    let
        app_ =
            setEditing
                newState
                app
    in
        Update.fromModel { model | app = app_ }


onEnterRename : Game.Data -> String -> Model -> UpdateResponse
onEnterRename data fileId ({ app } as model) =
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

        app_ =
            setEditing
                editing_
                app
    in
        Update.fromModel { model | app = app_ }


onApplyEdit : Game.Data -> Model -> UpdateResponse
onApplyEdit data ({ app } as model) =
    let
        fsMsg =
            data
                |> Game.getActiveCId
                |> Dispatch.filesystem

        gameMsg =
            case app.editing of
                NotEditing ->
                    Dispatch.none

                CreatingFile fName ->
                    if Filesystem.isValidFilename fName then
                        Dispatch.none
                    else
                        fsMsg <|
                            Filesystem.CreateTextFile ( app.path, fName )

                CreatingPath fName ->
                    if Filesystem.isValidFilename fName then
                        Dispatch.none
                    else
                        fsMsg <|
                            Filesystem.CreateEmptyDir ( app.path, fName )

                Moving fID ->
                    fsMsg <| Filesystem.Move fID app.path

                Renaming fID fName ->
                    if Filesystem.isValidFilename fName then
                        Dispatch.none
                    else
                        fsMsg <|
                            Filesystem.Rename fID fName

        app_ =
            setEditing
                NotEditing
                app

        model_ =
            { model | app = app_ }
    in
        ( model_, Cmd.none, gameMsg )
