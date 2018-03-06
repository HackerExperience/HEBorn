module OS.WindowManager.Sidebar.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Meta.Types.Desktop.Widgets exposing (..)
import OS.WindowManager.Sidebar.Config exposing (..)
import OS.WindowManager.Sidebar.Messages exposing (Msg(..), WidgetMsg(..))
import OS.WindowManager.Sidebar.Models exposing (..)
import OS.WindowManager.Sidebar.Shared exposing (..)
import Widgets.QuestHelper.Models as Quest
import Widgets.TaskList.Models as Tasks
import Widgets.TaskList.Update as Tasks


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        ToggleVisibility ->
            model
                |> getVisibility
                |> not
                |> flip setVisibility model
                |> React.update

        NewWidget widget ->
            onNewWidget config widget model

        Remove id ->
            model
                |> remove id
                |> React.update

        Prioritize id ->
            model
                |> prioritize id
                |> React.update

        Deprioritize id ->
            model
                |> deprioritize id
                |> React.update

        WidgetMsg widgetID msg ->
            onWidgetMsg config widgetID msg model


onWidgetMsg :
    Config msg
    -> WidgetId
    -> WidgetMsg
    -> Model
    -> UpdateResponse msg
onWidgetMsg config widgetID msg model =
    model
        |> getOrPretend widgetID
        |> updateWidget config widgetID msg
        |> Tuple.mapFirst
            (flip (insert widgetID) model)


onNewWidget : Config msg -> DesktopWidget -> Model -> UpdateResponse msg
onNewWidget _ widget model =
    let
        widgetModel =
            case widget of
                QuestHelper ->
                    Native.Panic.crash "Bad boy"
                        "QuestHelper must be generated from story"

                TaskList ->
                    TaskListModel Tasks.initialModel

        widget_ =
            Local (LocalWidget True 0 widgetModel)

        ( id, model0 ) =
            getNewWidgetId model

        model_ =
            insert id widget_ model0
    in
        React.update model_



-- internals


type alias WidgetResponse msg =
    ( Widget, React msg )


updateWidget :
    Config msg
    -> WidgetId
    -> WidgetMsg
    -> Widget
    -> WidgetResponse msg
updateWidget config id msg widget =
    case msg of
        ToggleExpanded ->
            widget
                |> map toggleExpanded toggleExpanded
                |> React.update

        IncreaseOrder ->
            widget
                |> map increaseOrder increaseOrder
                |> React.update

        DecreaseOrder ->
            widget
                |> map decreaseOrder decreaseOrder
                |> React.update

        _ ->
            case widget of
                Local widget ->
                    updateLocalWidget config id msg widget

                External _ ->
                    React.update widget


updateLocalWidget :
    Config msg
    -> WidgetId
    -> WidgetMsg
    -> LocalWidget
    -> WidgetResponse msg
updateLocalWidget config id msg widget =
    case widget.model of
        QuestHelperModel _ ->
            -- ALWAYS EXTERNAL
            React.update <| Local widget

        TaskListModel model ->
            case msg of
                TaskListMsg msg ->
                    model
                        |> Tasks.update (taskListConfig id config) msg
                        |> Tuple.mapFirst
                            (TaskListModel >> flip setModel widget >> Local)

                _ ->
                    React.update <| Local widget
