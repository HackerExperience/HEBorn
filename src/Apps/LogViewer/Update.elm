module Apps.LogViewer.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Utils.Update as Update
import Game.Data as Game
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
        -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            let
                ( menu_, cmd, dispatch ) =
                    Menu.update data msg model.menu

                cmd_ =
                    Cmd.map MenuMsg cmd

                model_ =
                    { model | menu = menu_ }
            in
                ( model_, cmd_, dispatch )

        -- -- Real acts
        ToogleExpand id ->
            { model | app = toggleExpand id app }
                |> Update.fromModel

        UpdateTextFilter filter ->
            { model | app = updateTextFilter data filter app }
                |> Update.fromModel

        EnterEditing id ->
            enterEditing data id model
                |> Update.fromModel

        UpdateEditing id input ->
            { model | app = updateEditing id input app }
                |> Update.fromModel

        LeaveEditing id ->
            { model | app = leaveEditing id app }
                |> Update.fromModel

        ApplyEditing id ->
            let
                edited =
                    getEdit id app

                model_ =
                    { model | app = leaveEditing id app }

                cid =
                    Game.getActiveCId data

                dispatch =
                    case edited of
                        Just edited ->
                            edited
                                |> Servers.UpdateLog id
                                |> Dispatch.logs cid

                        Nothing ->
                            Dispatch.none
            in
                ( model_, Cmd.none, dispatch )

        StartCrypting id ->
            let
                dispatch =
                    id
                        |> Servers.EncryptLog
                        |> Dispatch.logs (Game.getActiveCId data)
            in
                ( model, Cmd.none, dispatch )

        StartDecrypting id ->
            let
                dispatch =
                    id
                        |> Servers.DecryptLog
                        |> Dispatch.logs (Game.getActiveCId data)
            in
                ( model, Cmd.none, dispatch )

        StartHiding id ->
            let
                dispatch =
                    id
                        |> Servers.HideLog
                        |> Dispatch.logs (Game.getActiveCId data)
            in
                ( model, Cmd.none, dispatch )

        StartDeleting id ->
            let
                dispatch =
                    id
                        |> Servers.DeleteLog
                        |> Dispatch.logs (Game.getActiveCId data)
            in
                ( model, Cmd.none, dispatch )

        DummyNoOp ->
            ( model, Cmd.none, Dispatch.none )
