module OS.Console.View exposing (view)

import Dict exposing (Dict)
import Game.Data as Game
import Game.BackFlix.Models as BackFlix
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
            viewLogs (Game.getBackFlix data) ++ [ text "elliot@localhost_>" ]
    in
        div [ class [ LogConsole ] ]
            view_


viewLogs : BackFlix.BackFlix -> List (Html msg)
viewLogs logs =
    logs
        |> Dict.foldl (\k v acc -> viewLog k v :: acc) []


viewLog : BackFlix.Id -> BackFlix.Log -> Html msg
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


setClass : BackFlix.Log -> List (Html.Attribute msg)
setClass log =
    case log.type_ of
        BackFlix.Request ->
            [ class [ BFRequest ] ]

        BackFlix.Receive ->
            [ class [ BFReceive ] ]

        BackFlix.Join ->
            [ class [ BFJoin ] ]

        BackFlix.JoinAccount ->
            [ class [ BFJoinAccount ] ]

        BackFlix.JoinServer ->
            [ class [ BFJoinServer ] ]

        BackFlix.Other ->
            [ class [ BFOther ] ]

        BackFlix.None ->
            [ class [ BFNone ] ]

        BackFlix.Event ->
            [ class [ BFEvent ] ]

        BackFlix.Error ->
            [ class [ BFError ] ]
