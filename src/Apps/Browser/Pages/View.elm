module Apps.Browser.Pages.View exposing (view)

import Html exposing (Html, div, text)
import Game.Data as GameData
import Apps.Browser.Pages.Models exposing (..)
import Apps.Browser.Pages.Messages exposing (..)
import Apps.Browser.Pages.Blank.View as Blank
import Apps.Browser.Pages.NotFound.View as NotFound


view : GameData.Data -> Model -> Html Msg
view data model =
    case model of
        NotFoundModel _ ->
            Html.map (always NotFoundMsg) NotFound.view

        BlankModel ->
            Html.map (always BlankMsg) Blank.view

        UnknownModel ->
            div [] []

        _ ->
            Html.map (always UnknownMsg) Blank.view
