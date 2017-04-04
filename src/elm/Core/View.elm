module Core.View exposing (view)


import Html exposing (Html, div, text)

import Router.Router exposing (Route(..))
import Game.Models.Account exposing (isAuthenticated)
import Core.Messages exposing (Msg(..))
import Core.Models exposing (Model)
import Apps.Landing.View
import Apps.Dashboard.View


view : Model -> Html Msg
view model =
    page model


page : Model -> Html Msg
page model =
    if isAuthenticated model.core.account then
        Html.map MsgCore (Apps.Dashboard.View.view model)

    else
        case model.route of
            RouteNotFound ->
                notFoundView

            _ ->
                landingView model



landingView : Model -> Html Msg
landingView model =
    Apps.Landing.View.view model


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]
