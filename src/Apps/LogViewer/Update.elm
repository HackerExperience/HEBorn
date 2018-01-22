module Apps.LogViewer.Update exposing (update)

import Dict
import Utils.React as React exposing (React)
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


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse msg
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

                ( menu_, react ) =
                    Menu.update config_ msg model.menu

                model_ =
                    { model | menu = menu_ }
            in
                ( model_, react )

        -- -- Real acts
        ToogleExpand id ->
            ( toggleExpand id model, React.none )

        UpdateTextFilter filter ->
            ( updateTextFilter config filter model, React.none )

        EnterEditing id ->
            ( enterEditing (menuConfig config) id model, React.none )

        UpdateEditing id input ->
            ( updateEditing id input model, React.none )

        LeaveEditing id ->
            ( leaveEditing id model, React.none )

        ApplyEditing id ->
            let
                edited =
                    getEdit id model

                model_ =
                    leaveEditing id model

                react =
                    case edited of
                        Just edited ->
                            edited
                                |> config.onUpdateLog id
                                |> React.msg
                        Nothing ->
                            React.none
            in
                ( model_, react )

        StartCrypting id ->
            startCrypting (menuConfig config) id model

        StartDecrypting id ->
            startDecrypting (menuConfig config) id model

        StartHiding id ->
            startHiding (menuConfig config) id model

        StartDeleting id ->
            startDeleting (menuConfig config) id model

        DummyNoOp ->
            ( model, React.none )


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
