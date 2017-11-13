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
    exposing
        ( startCrypting
        , startDecrypting
        , startHiding
        , startDeleting
        )


update :
    Game.Data
    -> LogViewer.Msg
    -> Model
    -> ( Model, Cmd LogViewer.Msg, Dispatch )
update data msg model =
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
            model
                |> toggleExpand id
                |> Update.fromModel

        UpdateTextFilter filter ->
            model
                |> updateTextFilter data filter
                |> Update.fromModel

        EnterEditing id ->
            model
                |> enterEditing data id
                |> Update.fromModel

        UpdateEditing id input ->
            model
                |> updateEditing id input
                |> Update.fromModel

        LeaveEditing id ->
            model
                |> leaveEditing id
                |> Update.fromModel

        ApplyEditing id ->
            let
                edited =
                    getEdit id model

                model_ =
                    leaveEditing id model

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
                    startCrypting id data model
            in
                ( model, Cmd.none, dispatch )

        StartDecrypting id ->
            let
                dispatch =
                    startDecrypting id model
            in
                ( model, Cmd.none, dispatch )

        StartHiding id ->
            let
                dispatch =
                    startHiding id data model
            in
                ( model, Cmd.none, dispatch )

        StartDeleting id ->
            let
                dispatch =
                    startDeleting id data model
            in
                ( model, Cmd.none, dispatch )

        DummyNoOp ->
            ( model, Cmd.none, Dispatch.none )
