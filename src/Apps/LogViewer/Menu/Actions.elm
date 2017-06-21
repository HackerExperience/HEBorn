module Apps.LogViewer.Menu.Actions exposing (actionHandler)

import Core.Messages as Core
import Core.Dispatcher exposing (callLogs)
import Game.Models as Game
import Game.Servers.Logs.Messages as Logs exposing (Msg(..))
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Messages as LogViewer exposing (Msg(..))
import Apps.LogViewer.Menu.Messages exposing (ActionMsg(..))


actionHandler :
    ActionMsg
    -> Model
    -> Game.Model
    -> ( Model, Cmd LogViewer.Msg, List Core.Msg )
actionHandler action ({ app } as model) game =
    case action of
        NormalEntryEdit logId ->
            ( enterEditing game.servers model logId
            , Cmd.none
            , []
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
                            [ callLogs
                                "localhost"
                                (Logs.UpdateContent logId edited)
                            ]

                        Nothing ->
                            []
                    )
            in
                ( { model | app = app_ }, Cmd.none, gameMsg )

        EdittingEntryCancel logId ->
            let
                app_ =
                    leaveEditing app logId
            in
                ( { model | app = app_ }, Cmd.none, [] )
