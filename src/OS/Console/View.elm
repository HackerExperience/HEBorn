module OS.Console.View exposing (view)

import Dict exposing (Dict)
import Game.Data as Game
import Game.BackFeed.Models as BackFeed
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (..)
import Html.CssHelpers
import OS.Console.Messages exposing (Msg(..))
import Utils.LogFlix.Helpers as LogColor
import UI.ToString exposing (timestampToFullData)
import OS.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "os"


view : Game.Data -> Html msg
view data =
    let
        view_ =
            viewLogs (Game.getBackFeed data) ++ [ text "/home/OLOCOBIXO_>" ]
    in
        div [ class [ LogConsole ] ]
            view_


viewLogs : BackFeed.BackFeed -> List (Html msg)
viewLogs logs =
    logs
        |> Dict.toList
        |> List.map (uncurry <| viewLog)


viewLog : BackFeed.Id -> BackFeed.BackLog -> Html msg
viewLog id log =
    let
        data =
            text (toString log.data)

        type_ =
            text (log.typeString)

        time =
            timestampToFullData log.timestamp

        setClass =
            case log.type_ of
                BackFeed.Request ->
                    [ class [ BFRequest ] ]

                BackFeed.Receive ->
                    [ class [ BFReceive ] ]

                BackFeed.Join ->
                    [ class [ BFJoin ] ]

                BackFeed.JoinAccount ->
                    [ class [ BFJoinAccount ] ]

                BackFeed.JoinServer ->
                    [ class [ BFJoinServer ] ]

                BackFeed.Other ->
                    [ class [ BFOther ] ]

                BackFeed.None ->
                    [ class [ BFNone ] ]

                BackFeed.Event ->
                    [ class [ BFEvent ] ]

                BackFeed.Error ->
                    [ class [ BFError ] ]
    in
        div []
            [ div [ class [ LogConsoleHeader ] ]
                [ span
                    setClass
                    [ type_ ]
                , span [] [ text " " ]
                , span [] [ text time ]
                ]
            , div []
                [ data ]
            ]
