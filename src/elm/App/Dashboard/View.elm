module App.Dashboard.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)

import Router.Router exposing (Route(..))

import App.Models exposing (Model)
import App.Messages exposing (Msg(MsgSignUp, MsgLogin))
import App.Core.Models as CoreModel


import Html.CssHelpers
import App.Dashboard.Style as Style

{id, class, classList} =
    Html.CssHelpers.withNamespace "dreamwriter"

view : Model -> Html Msg
view model =
    case model.route of
        RouteHome ->
            viewDashboard model.core

        RouteNotFound ->
            viewNotFound

viewDashboard : CoreModel.Model -> Html Msg
viewDashboard core =
    div [ id "view-dashboard" ]
        [ viewHeader core
        , viewSidebar core
        , viewMain core
        , viewFooter core
        ]

viewHeader : CoreModel.Model -> Html Msg
viewHeader core =
    header []
        []

        -- lol;a
viewSidebar : CoreModel.Model -> Html Msg
viewSidebar core =
    nav []
        []


viewMain : CoreModel.Model -> Html Msg
viewMain core =
    main_ [ ]
       [ text "abcdef" ]

viewFooter : CoreModel.Model -> Html Msg
viewFooter core =
    footer []
        []


viewNotFound : Html Msg
viewNotFound =
    div []
        [ text "Not found"
        ]
-- viewLogin : Model -> Html Msg
-- viewLogin model =
--     Html.map MsgLogin (App.Login.View.view model.appLogin model.core)

-- viewSignUp : Model -> Html Msg
-- viewSignUp model =
--     Html.map MsgSignUp (App.SignUp.View.view model.appSignUp model.core)
