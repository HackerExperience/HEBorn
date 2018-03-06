module Apps.BackFlix.View exposing (view)

import Dict exposing (Dict)
import Html exposing (..)
import Html.CssHelpers
import UI.ToString exposing (timestampToFullData)
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Elements.FilterHeader exposing (filterHeader)
import UI.Elements.HorizontalTabs exposing (hzTabs)
import Game.BackFlix.Models as BackFlix
import Apps.BackFlix.Config exposing (..)
import Apps.BackFlix.Messages exposing (Msg(..))
import Apps.BackFlix.Models exposing (..)
import Apps.BackFlix.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config model =
    let
        backFlix =
            config.logs

        filterHeaderLayout =
            verticalList []
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
                    viewTabAll backFlix

                TabSimple ->
                    viewTabSimple backFlix
    in
        Html.map config.toMsg <|
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


viewTabAll : BackFlix.Model -> Html Msg
viewTabAll backflix =
    renderEntries backflix True


viewTabSimple : BackFlix.Model -> Html Msg
viewTabSimple backflix =
    let
        filter id log =
            case log.type_ of
                BackFlix.Other ->
                    False

                _ ->
                    True
    in
        renderEntries (Dict.filter filter backflix) False



-- internals


renderEntries : Dict BackFlix.Id BackFlix.Log -> Bool -> Html Msg
renderEntries logs useString =
    logs
        |> Dict.foldl (\k v acc -> renderEntry useString k v :: acc) []
        |> verticalList []


renderEntry : Bool -> BackFlix.Id -> BackFlix.Log -> Html Msg
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


setTypeLog : BackFlix.Log -> List (Html.Attribute Msg)
setTypeLog log =
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
