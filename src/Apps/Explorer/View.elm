module Apps.Explorer.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import UI.Widgets exposing (progressBar)
import UI.ToString exposing (bytesToString, secondsToTimeNotation)
import Css exposing (pct, width, asPairs)
import Game.Models exposing (GameModel)
import Game.Servers.Filesystem.Models as Filesystem exposing (..)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Models exposing (Model, Explorer)
import Apps.Explorer.Lib exposing (..)
import Apps.Explorer.Menu.View
    exposing
        ( menuView
        , menuMainDir
        , menuTreeDir
        , menuMainArchive
        , menuTreeArchive
        , menuExecutable
        , menuActiveAction
        , menuPassiveAction
        )
import Apps.Explorer.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "explorer"



-- VIEW WRAPPER


entryIcon : File -> Classes
entryIcon file =
    case file of
        Folder _ ->
            CasedDirIcon

        StdFile prop ->
            case (extensionInterpret prop.extension) of
                Virus ->
                    VirusIcon

                Firewall ->
                    FirewallIcon

                GenericArchive ->
                    GenericArchiveIcon


moduleIcon : KnownModule -> Classes
moduleIcon modType =
    case modType of
        Active ->
            ActiveIcon

        Passive ->
            PassiveIcon


moduleMenu : KnownModule -> Attribute Msg
moduleMenu modType =
    case modType of
        Active ->
            menuActiveAction

        Passive ->
            menuPassiveAction


fileVerToText : FileVersion -> Html Msg
fileVerToText ver =
    text
        (case ver of
            FileVersionNumber pure ->
                toString pure

            NoVersion ->
                "N/V"
        )


moduleVerToText : ModuleVersion -> Html Msg
moduleVerToText ver =
    text (toString ver)


sizeToText : FileSize -> Html Msg
sizeToText size =
    text
        (case size of
            FileSizeNumber pure ->
                bytesToString (toFloat pure)

            NoSize ->
                "N/S"
        )


renderModule : FileModule -> Html Msg
renderModule act =
    let
        target =
            moduleInterpret act.name
    in
        div [ moduleMenu target ]
            [ span [ class [ moduleIcon target ] ] []
            , span [] [ text act.name ]
            , span [] [ moduleVerToText act.version ]
            , span [] []
            ]


renderModuleList : List FileModule -> List (Html Msg)
renderModuleList acts =
    List.map (\o -> renderModule o) acts


indvidualEntryName : File -> String
indvidualEntryName file =
    case file of
        StdFile _ ->
            getFileName file

        Folder data ->
            data.name


renderTreeEntry : File -> Html Msg
renderTreeEntry file =
    div
        [ class [ NavEntry, EntryArchive ], menuTreeArchive ]
        [ span [ class [ NavIcon, entryIcon file ] ] []
        , span [] [ text (indvidualEntryName file) ]
        ]


renderTreeEntryList : List File -> List (Html Msg)
renderTreeEntryList list =
    List.map (\o -> renderTreeEntry o) list


renderDetailedEntry : File -> Html Msg
renderDetailedEntry file =
    case file of
        Folder data ->
            div [ class [ CntListEntry, EntryDir ], menuMainDir ]
                [ span [ class [ DirIcon ] ] []
                , span [] [ text data.name ]
                ]

        StdFile prop ->
            (case (extensionInterpret prop.extension) of
                GenericArchive ->
                    div [ class [ CntListEntry, EntryArchive ], menuMainArchive ]
                        [ span [ class [ entryIcon file ] ] []
                        , span [] [ text (indvidualEntryName file) ]
                        , span [] [ fileVerToText prop.version ]
                        , span [] [ sizeToText prop.size ]
                        ]

                _ ->
                    let
                        baseEntry =
                            div [ class [ CntListEntry, EntryArchive ], menuExecutable ]
                                [ span [ class [ entryIcon file ] ] []
                                , span [] [ text (indvidualEntryName file) ]
                                , span [] [ fileVerToText prop.version ]
                                , span [] [ sizeToText prop.size ]
                                ]
                    in
                        if (List.length prop.modules > 0) then
                            div [ class [ CntListContainer ] ]
                                [ baseEntry
                                , div [ class [ CntListChilds ] ]
                                    (renderModuleList prop.modules)
                                ]
                        else
                            baseEntry
            )


renderDetailedEntryList : List File -> List (Html Msg)
renderDetailedEntryList list =
    List.map (\o -> renderDetailedEntry o) list



-- END OF THAT


view : GameModel -> Model -> Html Msg
view game ({ app } as model) =
    div [ class [ Window ] ]
        [ viewExplorerColumn app game
        , viewExplorerMain app game
        , menuView model
        ]


viewUsage : Float -> Float -> Html Msg
viewUsage min max =
    let
        usage =
            min / max

        minStr =
            bytesToString min

        maxStr =
            bytesToString max
    in
        div [ class [ NavData ] ]
            [ text "Data usage"
            , br [] []
            , text (toString (floor (usage * 100)) ++ "%")
            , br [] []
            , progressBar usage "" 12
            , br [] []
            , text (minStr ++ " / " ++ maxStr)
            ]


viewExplorerColumn : Explorer -> GameModel -> Html Msg
viewExplorerColumn explorer game =
    div
        [ class [ Nav ]
        ]
        [ div [ class [ NavTree ] ]
            (renderTreeEntryList [])
        , (viewUsage 256000000 1024000000)
        ]


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
            (path |> pathInterpret |> pathFuckStart)
        )


viewExplorerMain : Explorer -> GameModel -> Html Msg
viewExplorerMain explorer game =
    div
        [ class
            [ Content ]
        ]
        [ div
            [ class [ ContentHeader ] ]
            [ viewLocBar explorer.path
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
            (renderDetailedEntryList [])
        ]
