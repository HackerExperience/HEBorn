module Setup.View exposing (view)

import Game.Models as Game
import Native.Untouchable
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.CssHelpers
import Setup.Types exposing (..)
import Setup.Messages exposing (..)
import Setup.Models exposing (..)
import Setup.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Model -> Model -> Html Msg
view game model =
    if isLoading model then
        loadingView
    else
        case model.page of
            Nothing ->
                loadingView

            Just page ->
                setupView game page model


loadingView : Html Msg
loadingView =
    div []
        [ p [] [ text "Keyboard not found" ]
        , p [] [ text "Press Ctrl+W to quit, keep waiting to continue..." ]
        ]


setupView : Game.Model -> PageModel -> Model -> Html Msg
setupView game page model =
    node setupNode
        []
        [ leftBar page model.pages
        , pageBase <| viewPage game page
        ]


pageBase : Html Msg -> Html Msg
pageBase content =
    node contentNode
        [ class [ StepWelcome ] ]
        [ div [] [ h1 [] [ text " D'LayDOS" ] ]
        , content
        ]


leftBar : PageModel -> List PageModel -> Html Msg
leftBar =
    let
        mapMarker page step =
            stepMarker page step

        view page pages =
            node leftBarNode
                []
                [ ul [] <| List.map (mapMarker page) pages
                ]
    in
        view


viewPage : Game.Model -> PageModel -> Html Msg
viewPage game page =
    case page of
        WelcomeModel ->
            --Welcome.view
            div [] []

        CustomWelcomeModel ->
            div [] []

        SetHostnameModel _ ->
            div [] []

        PickLocationModel ->
            div [] []

        ChooseThemeModel ->
            div [] []

        FinishModel ->
            div [] []


stepMarker : PageModel -> PageModel -> Html Msg
stepMarker active other =
    let
        isSelected =
            if active == other then
                [ class [ Selected ] ]
            else
                []
    in
        li isSelected [ text <| pageModelToString other ]
