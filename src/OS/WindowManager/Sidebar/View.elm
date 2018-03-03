module OS.WindowManager.Sidebar.View exposing (view)

import Dict exposing (Dict)
import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Set
import OS.WindowManager.Sidebar.Config exposing (..)
import OS.WindowManager.Sidebar.Messages exposing (Msg(..))
import OS.WindowManager.Sidebar.Models exposing (..)
import OS.WindowManager.Sidebar.Shared exposing (..)
import OS.WindowManager.Sidebar.Resources as R
import OS.WindowManager.Sidebar.Generators.Story as Story
import Widgets.QuestHelper.View as Quest
import Widgets.TaskList.View as Tasks


view : Config msg -> Model -> List (Html msg)
view config model =
    if hasLocalWidgets model || Story.hasQuests config.story then
        [ toggler config (getVisibility model)
        , super config model
        ]
    else
        []


toggler : Config msg -> Bool -> Html msg
toggler { toMsg } isVisible =
    span
        [ onClick (toMsg ToggleVisibility)
        , class [ R.Toggler ]
        ]
    <|
        if isVisible then
            [ text ">>" ]
        else
            [ text "<<" ]


super : Config msg -> Model -> Html msg
super config model =
    model
        |> getWidgets
        |> widgets config (getPrioritized model)
        |> div [ class (superClasses model) ]


superClasses : Model -> List R.Classes
superClasses { isVisible } =
    if isVisible then
        [ R.Super, R.Visible ]
    else
        [ R.Super ]


widgets : Config msg -> Prioritized -> Widgets -> List (Html msg)
widgets config prioritized widgets =
    widgets
        |> merge (genStory config)
        |> Dict.toList
        |> List.sortBy (Tuple.second >> getOrder)
        |> List.partition (Tuple.first >> flip Set.member prioritized)
        |> uncurry (++)
        |> List.map (widget config)


widget : Config msg -> ( WidgetId, LocalWidget ) -> Html msg
widget config ( id, { isExpanded, model } ) =
    div [ class [ R.Widget ] ]
        [ header config id model
        , if isExpanded then
            content config id model
          else
            text ""
        ]


header : Config msg -> WidgetId -> WidgetModel -> Html msg
header config id model =
    div [ class [ R.WidgetHeader ] ]
        [ text (getTitle model) ]


content : Config msg -> WidgetId -> WidgetModel -> Html msg
content config id model =
    let
        view_ =
            case model of
                QuestHelperModel model ->
                    Quest.view model

                TaskListModel model ->
                    Tasks.view
                        (taskListConfig id config)
                        model
    in
        div [ class [ R.WidgetBody ] ] [ view_ ]



-- internals


{ id, class, classList } =
    Html.CssHelpers.withNamespace R.prefix


genStory : Config msg -> Dict WidgetId WidgetModel
genStory { story } =
    case story of
        Just story ->
            story
                |> Story.gen
                |> Dict.map (\_ -> QuestHelperModel)

        Nothing ->
            Dict.empty
