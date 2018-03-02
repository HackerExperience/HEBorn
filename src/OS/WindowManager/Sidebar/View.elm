module OS.WindowManager.Sidebar.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import OS.WindowManager.Sidebar.Config exposing (Config)
import OS.WindowManager.Sidebar.Messages exposing (Msg(..))
import OS.WindowManager.Sidebar.Models exposing (Model, hasWidgets)
import OS.WindowManager.Sidebar.Resources exposing (..)


view : Config msg -> Model -> List (Html msg)
view config model =
    if hasWidgets model then
        [ toggler config model.isVisible
        , super config model
        ]
    else
        []


toggler : Config msg -> Bool -> Html msg
toggler { toMsg } isVisible =
    span [ onClick (toMsg ToggleVisibility) ] <|
        if isVisible then
            [ text ">>" ]
        else
            [ text "<<" ]


super : Config msg -> Model -> Html msg
super config model =
    div [ class (superClasses model) ]
        [ text "" ]


superClasses : Model -> List Classes
superClasses { isVisible } =
    if isVisible then
        [ Super, Visible ]
    else
        [ Super ]


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix
