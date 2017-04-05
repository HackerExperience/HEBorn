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
            viewDashboard model.game


viewDashboard : GameModel -> Html GameMsg
viewDashboard game =
    div [ id "view-dashboard" ]
        [ viewHeader game
        , viewSidebar game
        , viewMain game
        , viewFooter game
        ]

viewHeader : GameModel -> Html GameMsg
viewHeader game =
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
viewSidebar game =
    nav []
        [ text "nav" ]


viewMain : GameModel -> Html GameMsg
viewMain game =
    main_ [ ]
       [ text "main" ]

viewFooter : GameModel -> Html GameMsg
viewFooter game =
    footer []
        []


viewNotFound : Html GameMsg
viewNotFound =
    div []
        [ text "Not found"
        ]
-- viewLogin : Model -> Html GameMsg
-- viewLogin model =
--     Html.map GameMsgLogin (Apps.Login.View.view model.appLogin model.game)

-- viewSignUp : Model -> Html GameMsg
-- viewSignUp model =
--     Html.map GameMsgSignUp (Apps.SignUp.View.view model.appSignUp model.game)
