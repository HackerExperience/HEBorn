module Apps.LogFlix.View exposing (view)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Time
import Date exposing (year, hour, minute, second, fromTime)
import Utils.Html exposing (spacer)
import UI.ToString exposing (timestampToFullData)
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Entries.FilterHeader exposing (filterHeader)
import UI.Inlines.Networking as Inlines exposing (user, addr, file)
import UI.Entries.Toogable exposing (toogableEntry)
import UI.Widgets.HorizontalBtnPanel exposing (horizontalBtnPanel)
import UI.Widgets.HorizontalTabs exposing (hzTabs)
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.LogStream.Models as LogStream
import Apps.LogFlix.Messages exposing (Msg(..))
import Apps.LogFlix.Models exposing (..)
import Apps.LogFlix.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data model =
    let
        data_ =
            Game.getLogStream data

        filterHeaderLayout =
            verticalList
                [ hzTabs (compareTabs model.selected) viewTabLabel GoTab tabs
                , filterHeader
                    []
                    []
                    model.filterText
                    "Search..."
                    UpdateTextFilter
                ]

        viewData =
            case model.selected of
                TabAll ->
                    viewTabAll data_

                TabSimple ->
                    viewTabSimple data_
    in
        verticalSticked
            (Just [ filterHeaderLayout ])
            [ viewData ]
            Nothing


compareTabs : MainTab -> MainTab -> Bool
compareTabs =
    (==)


tabs : List MainTab
tabs =
    [ TabAll
    , TabSimple
    ]


viewTabLabel : Bool -> MainTab -> ( List (Attribute Msg), List (Html Msg) )
viewTabLabel _ tab =
    tab
        |> tabToString
        |> text
        |> List.singleton
        |> (,) []


viewTabAll : LogStream.LogStream -> Html Msg
viewTabAll model =
    renderEntries model True


viewTabSimple : LogStream.LogStream -> Html Msg
viewTabSimple model =
    let
        filter id log =
            case log.type_ of
                LogStream.Other ->
                    False

                _ ->
                    True
    in
        renderEntries (Dict.filter filter model) False



-- internals


renderEntries : Dict LogStream.Id LogStream.Log -> Bool -> Html Msg
renderEntries logs useString =
    logs
        |> Dict.foldl (\k v acc -> renderEntry useString k v :: acc) []
        |> verticalList


renderEntry : Bool -> LogStream.Id -> LogStream.Log -> Html Msg
renderEntry useString id log =
    let
        data =
            text (toString log.data)

        type_ =
            if useString then
                text (log.typeString)
            else
                text (typeToString log)

        time simple =
            timestampToFullData log.timestamp

        timestamp =
            text (time <| not useString)
    in
        div [ class [ LogBox ] ]
            [ div [ class [ LogHeader ] ]
                [ div (setTypeLog log)
                    [ type_ ]
                , div []
                    [ timestamp ]
                ]
            , div [ class [ DataDiv ] ]
                [ data ]
            ]


setTypeLog : LogStream.Log -> List (Html.Attribute msg)
setTypeLog log =
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
