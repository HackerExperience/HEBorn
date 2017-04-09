module OS.View exposing (view)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.CssHelpers
import Router.Router exposing (Route(..))
import Core.Models exposing (Model)
import Core.Messages exposing (CoreMsg(..))
import Game.Messages exposing (GameMsg(..), call)
import Game.Account.Messages exposing (AccountMsg(Logout))
import OS.WindowManager.View
import OS.Dock.View


{ id, class, classList } =
    Html.CssHelpers.withNamespace "dreamwriter"


view : Model -> Html CoreMsg
view model =
    case model.route of
        RouteNotFound ->
            viewNotFound

        _ ->
            viewDashboard model


viewDashboard : Model -> Html CoreMsg
viewDashboard model =
    div [ id "view-dashboard" ]
        [ viewHeader model
        , viewSidebar model
        , viewMain model
        , viewFooter model
        ]


viewHeader : Model -> Html CoreMsg
viewHeader model =
    Html.map MsgGame
        (header []
            [ div [ id "header-left" ]
                []
            , div [ id "header-mid" ]
                []
            , div [ id "header-right" ]
                [ button [ onClick (call.account Logout) ]
                    [ text "logout" ]
                ]
            ]
        )


viewSidebar : Model -> Html CoreMsg
viewSidebar model =
    nav []
        [ text "nav" ]


viewMain : Model -> Html CoreMsg
viewMain model =
    main_ []
        [ OS.WindowManager.View.renderWindows model
        ]


viewFooter : Model -> Html CoreMsg
viewFooter model =
    footer []
        [ OS.Dock.View.view model ]


viewNotFound : Html CoreMsg
viewNotFound =
    div []
        [ text "Not found"
        ]
