module Apps.LogViewer.Update exposing (update)

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Utils.Update as Update
import Game.Servers.Logs.Models as Logs
import Apps.LogViewer.Config exposing (..)
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
        , enterEditing
        )


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse
update config msg model =
    case msg of
        -- Context
        MenuMsg (Menu.MenuClick action) ->
            let
                config_ =
                    menuConfig config
            in
                Menu.actionHandler config_ action model

        MenuMsg msg ->
            let
                config_ =
                    menuConfig config

                ( menu_, cmd, dispatch ) =
                    Menu.update config_ msg model.menu

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
                |> updateTextFilter config filter
                |> Update.fromModel

        EnterEditing id ->
            model
                |> enterEditing (menuConfig config) id
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

                --cid =
                --    config.activeCId
                --dispatch =
                --    case edited of
                --        Just edited ->
                --            edited
                --                |> Servers.UpdateLog id
                --                |> Dispatch.logs cid
                --        Nothing ->
                --            Dispatch.none
            in
                ( model_, Cmd.none, Dispatch.none )

        StartCrypting id ->
            let
                dispatch =
                    startCrypting id (menuConfig config) model
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
                    startHiding id (menuConfig config) model
            in
                ( model, Cmd.none, dispatch )

        StartDeleting id ->
            let
                dispatch =
                    startDeleting id (menuConfig config) model
            in
                ( model, Cmd.none, dispatch )

        DummyNoOp ->
            ( model, Cmd.none, Dispatch.none )


updateTextFilter : Config msg -> String -> Model -> Model
updateTextFilter config filter model =
    let
        filterer id log =
            case Logs.getContent log of
                Logs.NormalContent data ->
                    String.contains filter data.raw

                Logs.Encrypted ->
                    False

        filterCache =
            config.logs
                |> Logs.filter filterer
                |> Dict.keys
    in
        { model
            | filterText = filter
            , filterCache = filterCache
        }
