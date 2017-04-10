module Core.View exposing (view)

import Html exposing (Html, div, text)
import Router.Router exposing (Route(..))
import Game.Account.Models exposing (isAuthenticated)
import Core.Messages exposing (CoreMsg(..))
import Core.Models exposing (CoreModel)
import OS.View
import Apps.Landing.View


view : CoreModel -> Html CoreMsg
view model =
    page model


page : CoreModel -> Html CoreMsg
page model =
    if isAuthenticated model.game.account then
        OS.View.view model
    else
        case model.route of
            RouteNotFound ->
                notFoundView

            _ ->
                landingView model


landingView : CoreModel -> Html CoreMsg
landingView model =
    Html.map MsgApp (Apps.Landing.View.view model)


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]
