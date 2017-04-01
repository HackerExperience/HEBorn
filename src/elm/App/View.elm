module App.View exposing (view)


import Html exposing (Html, div, text)

import Router.Router exposing (Route(..))
import Core.Models.Account exposing (isAuthenticated)
import App.Messages exposing (Msg(..))
import App.Models exposing (Model)
import App.Landing.View
import App.Dashboard.View


view : Model -> Html Msg
view model =
    page model


page : Model -> Html Msg
page model =
    if isAuthenticated model.core.account then
        Html.map MsgCore (App.Dashboard.View.view model)

    else
        case model.route of
            RouteNotFound ->
                notFoundView

            _ ->
                landingView model



landingView : Model -> Html Msg
landingView model =
    App.Landing.View.view model


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]
