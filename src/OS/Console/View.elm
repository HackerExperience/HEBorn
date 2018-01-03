module OS.Console.View exposing (view)

import Dict exposing (Dict)
import Game.Data as Game
import Game.LogStream.Models as LogStream
import Html exposing (Html, div, span, text)
import Html.CssHelpers
import UI.ToString exposing (timestampToFullData)
import OS.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "os"


view : Game.Data -> Html msg
view data =
    let
        view_ =
            viewLogs (Game.getLogStream data) ++ [ text "elliot@localhost_>" ]
    in
        div [ class [ LogConsole ] ]
            view_


viewLogs : LogStream.LogStream -> List (Html msg)
viewLogs logs =
    logs
        |> Dict.foldl (\k v acc -> viewLog k v :: acc) []


viewLog : LogStream.Id -> LogStream.Log -> Html msg
viewLog id log =
    let
        data =
            text (toString log.data)

        type_ =
            text (log.typeString)

        time =
            timestampToFullData log.timestamp
    in
        div []
            [ div [ class [ LogConsoleHeader ] ]
                [ span (setClass log)
                    [ type_ ]
                , span [] [ text " " ]
                , span [] [ text time ]
                ]
            , div []
                [ data ]
            ]


setClass : LogStream.Log -> List (Html.Attribute msg)
setClass log =
    case log.type_ of
        LogStream.Request ->
            [ class [ BFRequest ] ]

        LogStream.Receive ->
            [ class [ BFReceive ] ]

        LogStream.Join ->
            [ class [ BFJoin ] ]

        LogStream.JoinAccount ->
            [ class [ BFJoinAccount ] ]

        LogStream.JoinServer ->
            [ class [ BFJoinServer ] ]

        LogStream.Other ->
            [ class [ BFOther ] ]

        LogStream.None ->
            [ class [ BFNone ] ]

        LogStream.Event ->
            [ class [ BFEvent ] ]

        LogStream.Error ->
            [ class [ BFError ] ]
