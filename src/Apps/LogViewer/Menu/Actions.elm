module Apps.LogViewer.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Game.Servers.Logs.Messages as Logs exposing (Msg(..))
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Messages as LogViewer exposing (Msg(..))
import Apps.LogViewer.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Model
    -> MenuAction
    -> Model
    -> ( Model, Cmd LogViewer.Msg, Dispatch )
actionHandler game action ({ app } as model) =
    case action of
        NormalEntryEdit logId ->
            ( enterEditing game.servers model logId
            , Cmd.none
            , Dispatch.none
            )

        EdittingEntryApply logId ->
            let
                edited =
                    getEdit app logId

                app_ =
                    leaveEditing app logId

                gameMsg =
                    (case edited of
                        Just edited ->
                            Dispatch.logs
                                "localhost"
                                (Logs.UpdateContent logId edited)

                        Nothing ->
                            Dispatch.none
                    )
            in
                ( { model | app = app_ }, Cmd.none, gameMsg )

        EdittingEntryCancel logId ->
            let
                app_ =
                    leaveEditing app logId
            in
                ( { model | app = app_ }, Cmd.none, Dispatch.none )
