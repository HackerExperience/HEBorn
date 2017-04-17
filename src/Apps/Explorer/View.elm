module Apps.Explorer.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Game.Models exposing (GameModel)
import Apps.Instances.Models as Instance exposing (InstanceID)
import Apps.Context as Context
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Context.Models exposing (Context(..))
import Apps.Explorer.Context.View exposing (contextView, contextNav, contextContent)
import Apps.Explorer.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "explorer"


view : Model -> InstanceID -> GameModel -> Html Msg
view model id game =
    div [ class [ Window ] ]
        [ viewExplorerColumn model game
        , viewExplorerMain model id game
        , contextView model id
        ]


viewExplorerColumn : Model -> GameModel -> Html Msg
viewExplorerColumn model game =
    div
        [ contextNav
        , class [ Nav ]
        ]
        [ text "sidebar" ]


viewExplorerMain : Model -> InstanceID -> GameModel -> Html Msg
viewExplorerMain model id game =
    div
        [ contextContent
        , class
            [ Content ]
        ]
        [ div
            [ class [ ContentHeader ] ]
            [ div
                [ class [ LocBar ] ]
                [ span
                    [ class [ BreadcrumbItem ] ]
                    [ text "home" ]
                , span
                    [ class [ BreadcrumbItem ] ]
                    [ text "root" ]
                , span
                    [ class [ BreadcrumbItem ] ]
                    [ text "Documents" ]
                ]
            , div
                [ class [ ActBtns ] ]
                [ span
                    [ class [ GoUpBtn ] ]
                    []
                , span
                    [ class [ DocBtn, NewBtn ] ]
                    []
                , span
                    [ class [ DirBtn, NewBtn ] ]
                    []
                ]
            ]
        , div
            [ class [ ContentList ] ]
            [ div [ class [ CntListEntry, EntryDir ] ]
                [ span [] []
                , span [] [ text "Downloads" ]
                ]
            , div [ class [ CntListEntry, EntryArchive ] ]
                [ span [ class [ VirusIcon ] ] []
                , span [] [ text "MyVirus.spam" ]
                , span [] [ text "2.3" ]
                , span [] [ text "230 MB" ]
                ]
            , div [ class [ CntListEntry, EntryArchive ] ]
                [ span [ class [ FirewallIcon ] ] []
                , span [] [ text "TheWall.fwl" ]
                , span [] [ text "4.0" ]
                , span [] [ text "230 MB" ]
                ]
            ]
        ]
