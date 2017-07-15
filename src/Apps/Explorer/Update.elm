module Apps.Explorer.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Messages as Filesystem
import Apps.Explorer.Models exposing (..)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Menu.Messages as Menu
import Apps.Explorer.Menu.Update as Menu
import Apps.Explorer.Menu.Actions exposing (actionHandler)


update : Game.Data -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update data msg ({ app } as model) =
    case msg of
        -- Menu
        MenuMsg (Menu.MenuClick action) ->
            actionHandler data action model

        MenuMsg msg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Menu.update data msg model.menu

                cmd_ =
                    Cmd.map MenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )

        -- General Acts
        GoPath newPath ->
            let
                newApp =
                    changePath
                        newPath
                        (Servers.getFilesystem data.server)
                        app

                model_ =
                    { model | app = newApp }
            in
                ( model_, Cmd.none, Dispatch.none )

        -- General Acts
        UpdateEditing newState ->
            let
                newApp =
                    setEditing
                        newState
                        app

                model_ =
                    { model | app = newApp }
            in
                ( model_, Cmd.none, Dispatch.none )

        -- General Acts
        EnterRename fileId ->
            let
                newApp =
                    setEditing
                        (Renaming fileId "TODO")
                        app

                model_ =
                    { model | app = newApp }
            in
                ( model_, Cmd.none, Dispatch.none )

        ApplyEdit ->
            let
                gameMsg =
                    Dispatch.filesystem data.id

                msg =
                    case app.editing of
                        NotEditing ->
                            Dispatch.none

                        CreatingFile fName ->
                            if Filesystem.isValidFilename fName then
                                Dispatch.none
                            else
                                gameMsg <|
                                    Filesystem.CreateTextFile ( app.path, fName )

                        CreatingPath fName ->
                            if Filesystem.isValidFilename fName then
                                Dispatch.none
                            else
                                gameMsg <|
                                    Filesystem.CreateEmptyDir ( app.path, fName )

                        Moving fID ->
                            gameMsg <| Filesystem.Move fID app.path

                        Renaming fID fName ->
                            if Filesystem.isValidFilename fName then
                                Dispatch.none
                            else
                                gameMsg <|
                                    Filesystem.Rename fID fName

                newApp =
                    setEditing
                        NotEditing
                        app

                model_ =
                    { model | app = newApp }
            in
                ( model_, Cmd.none, msg )
