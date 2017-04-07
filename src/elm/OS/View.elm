module OS.View exposing (view)


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.CssHelpers

import Router.Router exposing (Route(..))

import Core.Models exposing (Model)
import Core.Messages exposing (Msg(..))
import Game.Messages exposing (GameMsg(..), call)
import Game.Models exposing (GameModel)
import Game.Account.Messages exposing (AccountMsg(Logout))
import OS.WindowManager.View


{id, class, classList} =
    Html.CssHelpers.withNamespace "dreamwriter"


view : Model -> Html Msg
view model =
    case model.route of
        RouteNotFound ->
            viewNotFound

        _ ->
            viewDashboard model


viewDashboard : Model -> Html Msg
viewDashboard model =
    div [ id "view-dashboard" ]
        [ viewHeader model
        , viewSidebar model
        , viewMain model
        , viewFooter model
        ]

viewHeader : Model -> Html Msg
viewHeader model =
    Html.map MsgGame
    (header []
        [ div [ id "header-left" ]
            []
        , div [ id "header-mid" ]
            []
        , div [ id "header-right" ]
            [ button [ onClick (call.account Logout) ]
                [ text "logout" ] ]
        ]
    )

viewSidebar : Model -> Html Msg
viewSidebar model =
    nav []
        [ text "nav" ]


viewMain : Model -> Html Msg
viewMain model =
    main_ []
        [ OS.WindowManager.View.renderWindows model
        ]

viewFooter : Model -> Html Msg
viewFooter model =
    footer []
        []


viewNotFound : Html Msg
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
