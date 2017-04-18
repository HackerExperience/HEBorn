module Apps.Explorer.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Css exposing (pct, width, asPairs)
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
styles : List Css.Mixin -> Attribute Msg
styles =
    Css.asPairs >> style


view : Model -> GameModel -> Html Msg
view model game =
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
        [ div [ class [ NavTree ] ]
            [ div [ class [ NavEntry, EntryDir, EntryExpanded ] ]
                [ div
                    [ class [ EntryView ] ]
                    [ span [ class [ CasedDirIcon, NavIcon ] ] []
                    , span [] [ text "Pictures" ]
                    ]
                , div
                    [ class [ EntryChilds ] ]
                    [ div
                        [ class [ NavEntry, EntryArchive ] ]
                        [ span [ class [ GenericArchiveIcon, NavIcon ] ] []
                        , span [] [ text "Purple Lotus 1.jpg" ]
                        ]
                    , div
                        [ class [ NavEntry, EntryArchive ] ]
                        [ span [ class [ GenericArchiveIcon, NavIcon ] ] []
                        , span [] [ text "Blue Orchid.png" ]
                        ]
                    , div
                        [ class [ NavEntry, EntryDir ] ]
                        [ div
                            [ class [ EntryView ] ]
                            [ span [ class [ CasedDirIcon, NavIcon ] ] []
                            , span [] [ text "Other Flowers" ]
                            ]
                        , div
                            [ class [ EntryChilds ] ]
                            []
                        ]
                    ]
                ]
            , div [ class [ NavEntry, EntryDir, EntryExpanded ] ]
                [ div
                    [ class [ EntryView ] ]
                    [ span [ class [ CasedOpIcon, NavIcon ] ] []
                    , span [] [ text "Tree" ]
                    ]
                , div
                    [ class [ EntryChilds ] ]
                    [ div
                        [ class [ NavEntry, EntryDir ] ]
                        [ div
                            [ class [ EntryView ] ]
                            [ span [ class [ CasedOpIcon, NavIcon ] ] []
                            , span [] [ text "Branch" ]
                            ]
                        , div
                            [ class [ EntryChilds ] ]
                            []
                        ]
                    , div
                        [ class [ NavEntry, EntryDir ] ]
                        [ div
                            [ class [ EntryView ] ]
                            [ span [ class [ CasedOpIcon, NavIcon ] ] []
                            , span [] [ text "AnotherBranch" ]
                            ]
                        , div
                            [ class [ EntryChilds ] ]
                            []
                        ]
                    , div
                        [ class [ NavEntry, EntryArchive ] ]
                        [ text "A Leaf" ]
                    ]
                ]
            ]
        , div [ class [ NavData ] ]
            [ text "Data usage"
            , br [] []
            , text "82%"
            , br [] []
            , div
                [ class [ ProgBar ] ]
                [ div
                    [ class [ [ ProgFill ] ]
                    , styles [ Css.width (pct 50) ]
                    ]
                    []
                ]
            , br [] []
            , text "289 MB / 1000 MB"
            ]
        ]


viewExplorerMain : Model -> InstanceID -> GameModel -> Html Msg
viewExplorerMain model id game =
stripPath : FilePath -> FilePath
stripPath path =
    let
        stripRight =
            (if (String.right 1 path == "/") then
                (String.dropRight 1 path)
             else
                path
            )
    in
        (if (String.left 1 stripRight == "/") then
            (String.dropLeft 1 stripRight)
         else
            stripRight
        )


viewLocBar : FilePath -> Html Msg
viewLocBar path =
    div
        [ class [ LocBar ] ]
        (List.map
            (\o ->
                span
                    [ class [ BreadcrumbItem ] ]
                    [ text o ]
            )
            (String.split "/" (stripPath path))
        )


viewExplorerMain : Model -> GameModel -> Html Msg
viewExplorerMain model game =
    div
        [ contextContent
        , class
            [ Content ]
        ]
        [ div
            [ class [ ContentHeader ] ]
            [ viewLocBar model.path
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
                [ span [ class [ DirIcon ] ] []
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
