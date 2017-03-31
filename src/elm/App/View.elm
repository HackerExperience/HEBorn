module App.View exposing (view)

import Html exposing (Html, div, text)

import Router.Router exposing (Route(..))
import App.Messages exposing (Msg(..))
import App.Models exposing (Model)
import App.Landing.View
import App.Dashboard.View

view : Model -> Html Msg
view model =
    page model


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
            App.Dashboard.View.view model

notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]
