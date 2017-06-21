module Core.View exposing (view)

import Html exposing (..)
import Router.Router exposing (Route(..))
import Game.Account.Models exposing (isAuthenticated)
import Core.Messages exposing (..)
import Core.Models exposing (..)
import OS.View as OS
import Landing.View as Landing


view : Model -> Html Msg
view model =
    case model.route of
        RouteNotFound ->
            notFoundView

        _ ->
            page model


page : Model -> Html Msg
page model =
    if isAuthenticated model.game.account then
        Html.map OSMsg (OS.view model)
    else
        Html.map LandingMsg (Landing.view model)


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]
