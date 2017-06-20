module Apps.LogViewer.Update exposing (update)

import Core.Messages exposing (CoreMsg)
import Core.Dispatcher exposing (callLogs, callProcesses)
import Game.Models exposing (GameModel)
import Game.Servers.Logs.Messages as Logs exposing (Msg(..))
import Game.Servers.Processes.Templates as NewProcesses exposing (localLogCrypt)
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Messages as LogViewer exposing (Msg(..))
import Apps.LogViewer.Menu.Messages as MsgMenu
import Apps.LogViewer.Menu.Update
import Apps.LogViewer.Menu.Actions exposing (actionHandler)


update : LogViewer.Msg -> GameModel -> Model -> ( Model, Cmd LogViewer.Msg, List CoreMsg )
update msg game ({ app } as model) =
    case msg of
        -- -- Context
        MenuMsg (MsgMenu.MenuClick action) ->
            actionHandler action model game

        MenuMsg subMsg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Apps.LogViewer.Menu.Update.update subMsg model.menu game

                cmd_ =
                    Cmd.map MenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )

        -- -- Real acts
        ToogleExpand logId ->
            let
                app_ =
                    toggleExpand app logId
            in
                ( { model | app = app_ }, Cmd.none, [] )

        UpdateTextFilter filter ->
            let
                app_ =
                    updateTextFilter app game.servers filter
            in
                ( { model | app = app_ }, Cmd.none, [] )

        EnterEditing logId ->
            ( enterEditing game.servers model logId
            , Cmd.none
            , []
            )

        UpdateEditing logId input ->
            let
                app_ =
                    updateEditing app logId input
            in
                ( { model | app = app_ }, Cmd.none, [] )

        LeaveEditing logId ->
            let
                app_ =
                    leaveEditing app logId
            in
                ( { model | app = app_ }, Cmd.none, [] )

        ApplyEditing logId ->
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

        StartCrypting logId ->
            let
                gameMsg =
                    [ callProcesses
                        "localhost"
                        (NewProcesses.localLogCrypt 1.0 logId game.meta.lastTick)
                    ]
            in
                ( model, Cmd.none, gameMsg )

        StartUncrypting logId ->
            let
                gameMsg =
                    [ callLogs
                        "localhost"
                        (Logs.Uncrypt logId "NOT IMPLEMENTED YET")
                    ]
            in
                ( model, Cmd.none, gameMsg )

        StartHiding logId ->
            let
                gameMsg =
                    [ callLogs
                        "localhost"
                        (Logs.Hide logId)
                    ]
            in
                ( model, Cmd.none, gameMsg )

        StartDeleting logId ->
            let
                gameMsg =
                    [ callLogs
                        "localhost"
                        (Logs.Delete logId)
                    ]
            in
                ( model, Cmd.none, gameMsg )
