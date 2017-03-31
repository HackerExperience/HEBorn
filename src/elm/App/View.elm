module App.View exposing (view)

import Html exposing (Html, div, text)

import Router.Router exposing (Route(..))
import App.Messages exposing (Msg(..))
import App.Models exposing (Model)
import App.Landing.View

view : Model -> Html Msg
view model =
    div [] [ page model ]


page : Model -> Html Msg
page model =
    case model.core.token of
        Nothing ->
            case model.route of
                RouteHome ->
                    App.Landing.View.view model

                RouteNotFound ->
                    notFoundView

                -- _ - >
                --     siteView

        Just _ ->
            case model.route of
                RouteHome ->
                    homeView

                RouteNotFound ->
                    notFoundView

                -- _ ->
                --     homeView


homeView : Html msg
homeView =
    div [] [ text "logg" ]


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]
