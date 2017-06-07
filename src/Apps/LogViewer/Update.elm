module Apps.LogViewer.Update exposing (update)

import Core.Messages exposing (CoreMsg)
import Core.Dispatcher exposing (callLogs)
import Game.Models exposing (GameModel)
import Game.Servers.Logs.Messages as Logs exposing (Msg(..))
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
        ToogleLog logId ->
            let
                app_ =
                    toggleExpand app logId
            in
                ( { model | app = app_ }, Cmd.none, [] )

        UpdateFilter filter ->
            let
                app_ =
                    updateFilter app game.servers filter
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
