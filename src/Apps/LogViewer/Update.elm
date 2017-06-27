module Apps.LogViewer.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Servers.Logs.Messages as Logs exposing (Msg(..))
import Game.Servers.Processes.Templates as NewProcesses exposing (localLogCrypt)
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Messages as LogViewer exposing (Msg(..))
import Apps.LogViewer.Menu.Messages as Menu
import Apps.LogViewer.Menu.Update as Menu
import Apps.LogViewer.Menu.Actions as Menu


update :
    Game.Data
    -> LogViewer.Msg
    -> Model
    -> ( Model, Cmd LogViewer.Msg, Dispatch )
update data msg ({ app } as model) =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Menu.update data msg model.menu

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
                ( { model | app = app_ }, Cmd.none, Dispatch.none )

        UpdateTextFilter filter ->
            let
                app_ =
                    updateTextFilter data app filter
            in
                ( { model | app = app_ }, Cmd.none, Dispatch.none )

        EnterEditing logId ->
            ( enterEditing data model logId
            , Cmd.none
            , Dispatch.none
            )

        UpdateEditing logId input ->
            let
                app_ =
                    updateEditing app logId input
            in
                ( { model | app = app_ }, Cmd.none, Dispatch.none )

        LeaveEditing logId ->
            let
                app_ =
                    leaveEditing app logId
            in
                ( { model | app = app_ }, Cmd.none, Dispatch.none )

        ApplyEditing logId ->
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

        StartCrypting logId ->
            let
                gameMsg =
                    Dispatch.processes
                        "localhost"
                        (NewProcesses.localLogCrypt 1.0 logId data.game.meta.lastTick)
            in
                ( model, Cmd.none, gameMsg )

        StartUncrypting logId ->
            let
                gameMsg =
                    Dispatch.logs
                        "localhost"
                        (Logs.Uncrypt logId "NOT IMPLEMENTED YET")
            in
                ( model, Cmd.none, gameMsg )

        StartHiding logId ->
            let
                gameMsg =
                    Dispatch.logs
                        "localhost"
                        (Logs.Hide logId)
            in
                ( model, Cmd.none, gameMsg )

        StartDeleting logId ->
            let
                gameMsg =
                    Dispatch.logs
                        "localhost"
                        (Logs.Delete logId)
            in
                ( model, Cmd.none, gameMsg )

        DummyNoOp ->
            ( model, Cmd.none, Dispatch.none )
