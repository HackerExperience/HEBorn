module Apps.Dashboard.View exposing (view)


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.CssHelpers

import Router.Router exposing (Route(..))

import Core.Models exposing (Model)
import Game.Messages exposing (GameMsg(..), call)
import Game.Models exposing (GameModel)
import Game.Account.Messages exposing (AccountMsg(Logout))

import Apps.Dashboard.Style as Style


{id, class, classList} =
    Html.CssHelpers.withNamespace "dreamwriter"


view : Model -> Html GameMsg
view model =
    case model.route of
        RouteNotFound ->
            viewNotFound

        _ ->
            viewDashboard model.core


viewDashboard : GameModel -> Html GameMsg
viewDashboard core =
    div [ id "view-dashboard" ]
        [ viewHeader core
        , viewSidebar core
        , viewMain core
        , viewFooter core
        ]

viewHeader : GameModel -> Html GameMsg
viewHeader core =
    header []
        [ div [ id "header-left" ]
            []
        , div [ id "header-mid" ]
            []
        , div [ id "header-right" ]
            [ button [ onClick (call.account Logout) ]
                [ text "logout" ] ]
        ]

viewSidebar : GameModel -> Html GameMsg
viewSidebar core =
    nav []
        [ text "nav" ]


viewMain : GameModel -> Html GameMsg
viewMain core =
    main_ [ ]
       [ text "main" ]

viewFooter : GameModel -> Html GameMsg
viewFooter core =
    footer []
        []


viewNotFound : Html GameMsg
viewNotFound =
    div []
        [ text "Not found"
        ]
-- viewLogin : Model -> Html GameMsg
-- viewLogin model =
--     Html.map GameMsgLogin (Apps.Login.View.view model.appLogin model.core)

-- viewSignUp : Model -> Html GameMsg
-- viewSignUp model =
--     Html.map GameMsgSignUp (Apps.SignUp.View.view model.appSignUp model.core)
