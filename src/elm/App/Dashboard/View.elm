module App.Dashboard.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Router.Router exposing (Route(..))

import Core.Messages exposing (CoreMsg(..))
import Core.Models exposing (CoreModel)
import App.Models exposing (Model)


import Html.CssHelpers
import App.Dashboard.Style as Style

{id, class, classList} =
    Html.CssHelpers.withNamespace "dreamwriter"

view : Model -> Html CoreMsg
view model =
    case model.route of
        RouteNotFound ->
            viewNotFound

        _ ->
            viewDashboard model.core


viewDashboard : CoreModel -> Html CoreMsg
viewDashboard core =
    div [ id "view-dashboard" ]
        [ viewHeader core
        , viewSidebar core
        , viewMain core
        , viewFooter core
        ]

viewHeader : CoreModel -> Html CoreMsg
viewHeader core =
    header []
        [ div [ id "header-left" ]
            []
        , div [ id "header-mid" ]
            []
        , div [ id "header-right" ]
            [ button [ onClick (Logout) ]
                [ text "logout" ] ]
        ]

        -- lol;a
viewSidebar : CoreModel -> Html CoreMsg
viewSidebar core =
    nav []
        [ text "nav" ]


viewMain : CoreModel -> Html CoreMsg
viewMain core =
    main_ [ ]
       [ text "main" ]

viewFooter : CoreModel -> Html CoreMsg
viewFooter core =
    footer []
        []


viewNotFound : Html CoreMsg
viewNotFound =
    div []
        [ text "Not found"
        ]
-- viewLogin : Model -> Html CoreMsg
-- viewLogin model =
--     Html.map CoreMsgLogin (App.Login.View.view model.appLogin model.core)

-- viewSignUp : Model -> Html CoreMsg
-- viewSignUp model =
--     Html.map CoreMsgSignUp (App.SignUp.View.view model.appSignUp model.core)
