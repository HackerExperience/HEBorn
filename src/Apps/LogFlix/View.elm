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
import Utils.LogFlix.Helpers as LogColor
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.BackFeed.Models as BackFeed
import Apps.LogFlix.Messages exposing (Msg(..))
import Apps.LogFlix.Models exposing (..)
import Apps.LogFlix.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


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


viewTabAll : BackFeed.BackFeed -> List (Html Msg)
viewTabAll model =
    renderEntries model True


viewTabSimple : BackFeed.BackFeed -> List (Html Msg)
viewTabSimple model =
    let
        filter id log =
            case log.type_ of
                BackFeed.Other ->
                    False

                _ ->
                    True

        logs =
            model
    in
        renderEntries (Dict.filter filter logs) False


view : Game.Data -> Model -> Html Msg
view data model =
    let
        allSource =
            Game.getBackFeed data

        simpleSource =
            Game.getBackFeed data

        viewData =
            case model.selected of
                TabAll ->
                    viewTabAll allSource

                TabSimple ->
                    viewTabSimple simpleSource

        filterHeaderLayout =
            verticalList
                [ viewTabs
                , filterHeader
                    []
                    []
                    model.filterText
                    "Search..."
                    UpdateTextFilter
                ]

        viewTabs =
            hzTabs (compareTabs model.selected) viewTabLabel GoTab tabs
    in
        verticalSticked
            (Just [ filterHeaderLayout ])
            viewData
            Nothing



-- internals


renderEntries : Dict BackFeed.Id BackFeed.BackLog -> Bool -> List (Html Msg)
renderEntries logs use_string =
    logs
        |> Dict.toList
        |> List.map (uncurry <| renderEntry use_string)


renderEntry : Bool -> BackFeed.Id -> BackFeed.BackLog -> Html Msg
renderEntry use_string id log =
    let
        data =
            text (toString log.data)

        type_ =
            if use_string then
                text (log.typeString)
            else
                text (typeToString log)

        time simple =
            timestampToFullData log.timestamp

        timestamp =
            text (time <| not use_string)

        typeLog =
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
        div [ class [ LogBox ] ]
            [ div [ class [ LogHeader ] ]
                [ div typeLog
                    [ type_ ]
                , div []
                    [ timestamp ]
                ]
            , div [ class [ DataDiv ] ]
                [ data ]
            ]
