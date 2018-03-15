module OS.WindowManager.Sidebar.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Game.Storyline.Models as Story
import OS.WindowManager.Sidebar.Config exposing (..)
import OS.WindowManager.Sidebar.Messages exposing (..)
import OS.WindowManager.Sidebar.Models exposing (..)
import OS.WindowManager.Sidebar.Resources as R
import Widgets.QuestHelper.View as QuestHelper


view : Config msg -> Model -> List (Html msg)
view config model =
    [ toggler config (getVisibility model)
    , super config model
    ]



-- internals


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
    div
        [ class (superClasses model)
        , config.menuAttr []
        ]
        [ config.story
            |> Maybe.map (questHelper config)
            |> Maybe.withDefault (text "")
        ]


superClasses : Model -> List R.Classes
superClasses { isVisible } =
    if isVisible then
        [ R.Super, R.Visible ]
    else
        [ R.Super ]


questHelper : Config msg -> Story.Model -> Html msg
questHelper config story =
    story
        |> QuestHelper.view
        |> List.singleton
        |> div [ class [ R.WidgetBody ] ]
        |> \body ->
            div [ class [ R.Widget ] ]
                [ div
                    [ class [ R.WidgetHeader ] ]
                    [ text "Some title" ]
                , body
                ]


{ id, class, classList } =
    Html.CssHelpers.withNamespace R.prefix
