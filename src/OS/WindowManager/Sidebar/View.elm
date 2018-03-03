module OS.WindowManager.Sidebar.View exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Set
import OS.WindowManager.Sidebar.Config exposing (Config)
import OS.WindowManager.Sidebar.Messages exposing (Msg(..))
import OS.WindowManager.Sidebar.Models exposing (..)
import OS.WindowManager.Sidebar.Shared exposing (..)
import OS.WindowManager.Sidebar.Resources as R


view : Config msg -> Model -> List (Html msg)
view config model =
    if hasWidgets model then
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
        |> Dict.toList
        |> List.sortBy (Tuple.second >> getOrder)
        |> List.partition (Tuple.first >> flip Set.member prioritized)
        |> uncurry (++)
        |> List.map (widget config)


widget : Config msg -> ( WidgetID, Widget ) -> Html msg
widget config ( id, { isExpanded, model } ) =
    div [ class [ R.Widget ] ]
        [ header config id model
        , if isExpanded then
            content config id model
          else
            text ""
        ]


header : Config msg -> WidgetID -> WidgetModel -> Html msg
header config id model =
    div [ class [ R.WidgetHeader ] ]
        [ text (getTitle model) ]


content : Config msg -> WidgetID -> WidgetModel -> Html msg
content config id model =
    div [ class [ R.WidgetBody ] ] <|
        case model of
            QuestHelperModel _ ->
                []



-- internals


{ id, class, classList } =
    Html.CssHelpers.withNamespace R.prefix
