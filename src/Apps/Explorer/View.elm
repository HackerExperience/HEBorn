module Apps.Explorer.View exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.CssHelpers
import UI.Widgets exposing (progressBar)
import UI.ToString exposing (bytesToString, secondsToTimeNotation)
import Game.Models exposing (GameModel)
import Game.Servers.Models exposing (Servers)
import Game.Servers.Filesystem.Models as Filesystem exposing (..)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Models exposing (Model, Explorer, resolvePath)
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


moduleMenu : FileID -> KnownModule -> Attribute Msg
moduleMenu fileID modType =
    case modType of
        Active ->
            menuActiveAction fileID

        Passive ->
            menuPassiveAction fileID


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


renderModule : FileID -> FileModule -> Html Msg
renderModule fileID act =
    let
        target =
            moduleInterpret act.name
    in
        div [ moduleMenu fileID target ]
            [ span [ class [ moduleIcon target ] ] []
            , span [] [ text act.name ]
            , span [] [ moduleVerToText act.version ]
            , span [] []
            ]


renderModuleList : FileID -> List FileModule -> List (Html Msg)
renderModuleList fileID acts =
    List.map (renderModule fileID) acts


indvidualEntryName : File -> String
indvidualEntryName file =
    case file of
        StdFile _ ->
            getFileName file

        Folder data ->
            data.name


renderTreeEntry : Servers -> File -> Html Msg
renderTreeEntry servers file =
    let
        icon =
            span [ class [ NavIcon, entryIcon file ] ] []

        label =
            span [] [ text (indvidualEntryName file) ]
    in
        case file of
            Folder data ->
                div
                    [ class [ NavEntry, EntryDir, EntryExpanded ]
                    , menuTreeDir data.id
                    , onClick (GoPath (fullFilePath file))
                    ]
                    [ div
                        [ class [ EntryView ] ]
                        [ icon, label ]
                    , div
                        [ class [ EntryChilds ] ]
                        (renderTreeEntryPath servers (pathInterpret (fullFilePath file)))
                    ]

            StdFile prop ->
                div
                    [ class [ NavEntry, EntryArchive ]
                    , menuTreeArchive prop.id
                    ]
                    [ icon, label ]


renderTreeEntryPath : Servers -> SmartPath -> List (Html Msg)
renderTreeEntryPath servers path =
    let
        entries =
            resolvePath
                servers
                (path |> pathToString)
    in
        List.map (renderTreeEntry servers) entries


renderDetailedEntry : File -> Html Msg
renderDetailedEntry file =
    case file of
        Folder data ->
            div
                [ class [ CntListEntry, EntryDir ]
                , menuMainDir data.id
                , onClick (GoPath (fullFilePath file))
                ]
                [ span [ class [ DirIcon ] ] []
                , span [] [ text data.name ]
                ]

        StdFile prop ->
            (case (extensionInterpret prop.extension) of
                GenericArchive ->
                    div
                        [ class [ CntListEntry, EntryArchive ]
                        , menuMainArchive prop.id
                        ]
                        [ span [ class [ entryIcon file ] ] []
                        , span [] [ text (indvidualEntryName file) ]
                        , span [] [ fileVerToText prop.version ]
                        , span [] [ sizeToText prop.size ]
                        ]

                _ ->
                    let
                        baseEntry =
                            div
                                [ class [ CntListEntry, EntryArchive ]
                                , menuExecutable prop.id
                                ]
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
                                    (renderModuleList prop.id prop.modules)
                                ]
                        else
                            baseEntry
            )


renderDetailedEntryList : List File -> List (Html Msg)
renderDetailedEntryList list =
    List.map
        renderDetailedEntry
        list



-- END OF THAT


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


viewExplorerColumn : SmartPath -> Servers -> Html Msg
viewExplorerColumn path servers =
    div
        [ class [ Nav ]
        ]
        [ div [ class [ NavTree ] ]
            (renderTreeEntryPath
                servers
                path
            )
        , (viewUsage 256000000 1024000000)
        ]


viewLocBar : SmartPath -> Html Msg
viewLocBar path =
    div
        [ class [ LocBar ] ]
        (List.map
            (\o ->
                span
                    [ class [ BreadcrumbItem ] ]
                    [ text o ]
            )
            (path |> pathFuckStart)
        )


viewExplorerMain : SmartPath -> Servers -> Html Msg
viewExplorerMain path servers =
    div
        [ class
            [ Content ]
        ]
        [ div
            [ class [ ContentHeader ] ]
            [ viewLocBar path
            , div
                [ class [ ActBtns ] ]
                [ span
                    [ class [ GoUpBtn ]
                    , onClick (GoPath ((pathGoUp path) |> pathToString))
                    ]
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
            (renderDetailedEntryList
                (resolvePath
                    servers
                    (path |> pathToString)
                )
            )
        ]


view : GameModel -> Model -> Html Msg
view game ({ app } as model) =
    let
        nowPath =
            app.path |> pathInterpret

        x =
            Debug.log "Path: " nowPath
    in
        div [ class [ Window ] ]
            [ viewExplorerColumn (Absolute [ "favorites" ]) game.servers
            , viewExplorerMain nowPath game.servers
            , menuView model
            ]
