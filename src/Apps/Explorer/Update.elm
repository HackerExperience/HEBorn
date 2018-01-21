module Apps.Explorer.Update exposing (update)

import Utils.React as React exposing (React)
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Shared as Filesystem
import Apps.Explorer.Config exposing (..)
import Apps.Explorer.Models exposing (..)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Menu.Messages as Menu
import Apps.Explorer.Menu.Update as Menu
import Apps.Explorer.Menu.Actions exposing (actionHandler)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    let
        server =
            config.activeServer

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
                        let
                            config_ =
                                menuConfig config
                        in
                            actionHandler config action model

                    MenuMsg msg ->
                        onMenuMsg config msg model

                    -- General Acts
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

                    _ ->
                        -- TODO: implement folder operation requests
                        ( model, React.none )

            Nothing ->
                ( model, React.none )


onMenuMsg : Config msg -> Menu.Msg -> Model -> UpdateResponse msg
onMenuMsg config msg model =
    let
        ( menu_, react ) =
            Menu.update (menuConfig config) msg model.menu

        model_ =
            { model | menu = menu_ }
    in
        ( model_, react )


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
        storageId =
            getStorage config.activeServer model

        --fsMsg =
        --    Dispatch.filesystem config.activeCId storageId
        --gameMsg =
        --    case model.editing of
        --        NotEditing ->
        --            Dispatch.none
        --        CreatingFile fName ->
        --            if Filesystem.isValidFilename fName then
        --                Dispatch.none
        --            else
        --                fsMsg <| Servers.NewTextFile model.path fName
        --        CreatingPath fName ->
        --            if Filesystem.isValidFilename fName then
        --                Dispatch.none
        --            else
        --                fsMsg <| Servers.NewDir model.path fName
        --        Moving fID ->
        --            fsMsg <| Servers.MoveFile fID model.path
        --        Renaming fID fName ->
        --            if Filesystem.isValidFilename fName then
        --                Dispatch.none
        --            else
        --                fsMsg <| Servers.RenameFile fID fName
        --        _ ->
        --            -- TODO: implement folder operation requests
        --            Dispatch.none
        model_ =
            setEditing NotEditing model
    in
        ( model_, React.none )
