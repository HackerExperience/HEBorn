module Utils.LogFlix.Helpers exposing (getLogColor)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Time
import Date exposing (year, hour, minute, second, fromTime)
import Game.BackFeed.Models as BackFeed


getLogColor : BackFeed.BackLog -> Html.Attribute msg
getLogColor log =
    case log.type_ of
        BackFeed.Request ->
            style [ ( "color", "#0000FF" ) ]

        BackFeed.Receive ->
            style [ ( "color", "#00FFFF" ) ]

        BackFeed.Join ->
            style [ ( "color", "#00FF00" ) ]

        BackFeed.Event ->
            style [ ( "color", "#00FF77" ) ]

        BackFeed.Other ->
            style [ ( "color", "#777777" ) ]

        BackFeed.Error ->
            style [ ( "color", "#FF0000" ) ]

        _ ->
            style [ ( "color", "#FF00FF" ) ]
