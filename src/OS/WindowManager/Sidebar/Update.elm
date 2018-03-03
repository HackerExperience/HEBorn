module OS.WindowManager.Sidebar.Update exposing (update)

import Utils.React as React exposing (React)
import OS.WindowManager.Sidebar.Config exposing (Config)
import OS.WindowManager.Sidebar.Messages exposing (Msg(..), WidgetMsg(..))
import OS.WindowManager.Sidebar.Models exposing (..)
import OS.WindowManager.Sidebar.Shared exposing (..)


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

        NewWidget _ _ ->
            -- TODO
            React.update model

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
                    -- TODO
                    React.update <| Local <| widget

                External _ ->
                    React.update widget
