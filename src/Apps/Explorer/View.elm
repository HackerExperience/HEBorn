module Apps.Explorer.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (value)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers
import UI.Widgets.ProgressBar exposing (progressBar)
import UI.ToString exposing (bytesToString, secondsToTimeNotation)
import Game.Data as Game
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Filesystem.Shared exposing (..)
import Game.Servers.Filesystem.Models exposing (getEntryName, getEntryLink)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Models exposing (..)
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
import Apps.Explorer.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix



-- VIEW WRAPPER


entryIcon : Entry -> Classes
entryIcon file =
    case file of
        FolderEntry _ ->
            CasedDirIcon

        FileEntry prop ->
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
    ver
        |> Maybe.map toString
        |> Maybe.withDefault "N/V"
        |> text


moduleVerToText : ModuleVersion -> Html Msg
moduleVerToText ver =
    ver
        |> toString
        |> text


sizeToText : FileSize -> Html Msg
sizeToText size =
    size
        |> Maybe.map (toFloat >> bytesToString)
        |> Maybe.withDefault "N/S"
        |> text


module_ : FileID -> Module -> Html Msg
module_ fileID act =
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


moduleList : FileID -> List Module -> List (Html Msg)
moduleList fileID acts =
    List.map (module_ fileID) acts


treeEntry : Server -> Entry -> Html Msg
treeEntry server file =
    let
        icon =
            span [ class [ NavIcon, entryIcon file ] ] []

        label =
            span [] [ text <| getEntryName file ]
    in
        case file of
            FolderEntry data ->
                let
                    fs =
                        Servers.getFilesystem server

                    ( goLoc, goFolder ) =
                        getEntryLink file fs

                    meAsLoc =
                        goLoc ++ [ goFolder ]
                in
                    div
                        [ class [ NavEntry, EntryDir, EntryExpanded ]
                        , menuTreeDir data.id
                        , onClick <| GoPath meAsLoc
                        ]
                        [ div
                            [ class [ EntryView ] ]
                            [ icon, label ]
                        , div
                            [ class [ EntryChilds ] ]
                          <|
                            treeEntryPath server meAsLoc
                        ]

            FileEntry prop ->
                div
                    [ class [ NavEntry, EntryArchive ]
                    , menuTreeArchive prop.id
                    ]
                    [ icon, label ]


treeEntryPath : Server -> Location -> List (Html Msg)
treeEntryPath server path =
    path
        |> resolvePath server
        |> List.map (treeEntry server)


detailedEntry : Server -> Entry -> Html Msg
detailedEntry server file =
    case file of
        FolderEntry data ->
            let
                fs =
                    Servers.getFilesystem server

                ( goLoc, goFolder ) =
                    getEntryLink file fs

                meAsLoc =
                    goLoc ++ [ goFolder ]
            in
                div
                    [ class [ CntListEntry, EntryDir ]
                    , menuMainDir data.id
                    , onClick <| GoPath meAsLoc
                    ]
                    [ span [ class [ DirIcon ] ] []
                    , span [] [ text data.name ]
                    ]

        FileEntry prop ->
            (case (extensionInterpret prop.extension) of
                GenericArchive ->
                    div
                        [ class [ CntListEntry, EntryArchive ]
                        , menuMainArchive prop.id
                        ]
                        [ span [ class [ entryIcon file ] ] []
                        , span [] [ text <| getEntryName file ]
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
                                , span [] [ text <| getEntryName file ]
                                , span [] [ fileVerToText prop.version ]
                                , span [] [ sizeToText prop.size ]
                                ]
                    in
                        if (List.length prop.modules > 0) then
                            div [ class [ CntListContainer ] ]
                                [ baseEntry
                                , div [ class [ CntListChilds ] ] <|
                                    moduleList prop.id prop.modules
                                ]
                        else
                            baseEntry
            )


detailedEntryList : Server -> List Entry -> List (Html Msg)
detailedEntryList server list =
    List.map
        (detailedEntry server)
        list



-- END OF THAT


usage : Float -> Float -> Html Msg
usage min max =
    let
        usage =
            min / max

        minStr =
            bytesToString min

        maxStr =
            bytesToString max

        usageStr =
            (usage * 100)
                |> floor
                |> toString
    in
        div [ class [ NavData ] ]
            [ text "Data usage"
            , br [] []
            , text (usageStr ++ "%")
            , br [] []
            , progressBar usage "" 12
            , br [] []
            , text <| minStr ++ " / " ++ maxStr
            ]


explorerColumn : Location -> Server -> Html Msg
explorerColumn path server =
    div
        [ class [ Nav ]
        ]
        [ div [ class [ NavTree ] ] <|
            treeEntryPath
                server
                path
        , usage 256000000 1024000000
        ]


breadcrumbItem : Location -> String -> Html Msg
breadcrumbItem path label =
    span
        [ class [ BreadcrumbItem ]
        , onClick <| GoPath path
        ]
        [ text label ]


breadcrumbFold : String -> ( List (Html Msg), Location ) -> ( List (Html Msg), Location )
breadcrumbFold item ( htmlElems, pathAcu ) =
    if (String.length item) < 1 then
        ( htmlElems, pathAcu )
    else
        let
            fullPath =
                pathAcu ++ [ item ]

            newElems =
                item
                    |> breadcrumbItem fullPath
                    |> (flip (::)) htmlElems
        in
            ( newElems, fullPath )


breadcrumb : Location -> Html Msg
breadcrumb path =
    path
        |> List.foldl breadcrumbFold ( [], [] )
        |> Tuple.first
        |> List.reverse
        |> (::) (breadcrumbItem [] "DISK")
        |> div [ class [ LocBar ] ]


explorerMainHeader : Location -> Html Msg
explorerMainHeader path =
    div
        [ class [ ContentHeader ] ]
        [ breadcrumb path
        , div
            [ class [ ActBtns ] ]
            [ span
                [ class [ GoUpBtn ]
                , onClick <| GoPath <| locationGoUp path
                ]
                []
            , span
                [ class [ DocBtn, NewBtn ]
                , onClick <| UpdateEditing <| CreatingFile ""
                ]
                []
            , span
                [ class [ DirBtn, NewBtn ]
                , onClick <| UpdateEditing <| CreatingPath ""
                ]
                []
            ]
        ]


explorerMainDinamycContent : EditingStatus -> Html Msg
explorerMainDinamycContent editing =
    div [] <|
        case editing of
            NotEditing ->
                []

            CreatingFile nowName ->
                [ input
                    [ value nowName
                    , onInput <| CreatingFile >> UpdateEditing
                    ]
                    []
                , button [ onClick ApplyEdit ] [ text "CREATE FILE" ]
                ]

            CreatingPath nowName ->
                [ input
                    [ value nowName
                    , onInput <| CreatingPath >> UpdateEditing
                    ]
                    []
                , button [ onClick ApplyEdit ] [ text "CREATE PATH" ]
                ]

            Moving fileID ->
                [ button [ onClick ApplyEdit ] [ text "MOVE HERE" ]
                ]

            Renaming fileID newName ->
                [ input
                    [ value newName
                    , onInput <| (Renaming fileID) >> UpdateEditing
                    ]
                    []
                , button [ onClick ApplyEdit ] [ text "RENAME" ]
                ]


explorerMain : EditingStatus -> Location -> Server -> Html Msg
explorerMain editing path server =
    div
        [ class
            [ Content ]
        ]
        [ explorerMainHeader path
        , explorerMainDinamycContent editing
        , path
            |> resolvePath server
            |> detailedEntryList server
            |> div [ class [ ContentList ] ]
        ]


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    let
        nowPath =
            app.path
    in
        div [ class [ Window ] ]
            [ explorerColumn [] data.server
            , explorerMain app.editing nowPath data.server
            , menuView model
            ]
