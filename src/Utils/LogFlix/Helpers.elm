module Utils.LogFlix.Helpers exposing (getLogColor)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Time
import Date exposing (year, hour, minute, second, fromTime)
import Game.BackFeed.Models as BackFeed


getLogColor : BackFeed.BackLog -> ( String, String )
getLogColor log =
    case Debug.log "" log.type_ of
        BackFeed.Request ->
            ( "color", "#0000FF" )

        BackFeed.Receive ->
            ( "color", "#00FFFF" )

        BackFeed.Join ->
            ( "color", "#00FF00" )

        BackFeed.JoinAccount ->
            ( "color", "55FFFF" )

        BackFeed.JoinServer ->
            ( "color", "0000FF" )

        BackFeed.Event ->
            ( "color", "#00FF77" )

        BackFeed.Other ->
            ( "color", "#777777" )

        BackFeed.Error ->
            ( "color", "#FF0000" )

        _ ->
            ( "color", "#FF00FF" )
