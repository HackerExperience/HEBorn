module Apps.Explorer.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (value)
import Html.Events exposing (onClick)
import Html.CssHelpers
import UI.Widgets.ProgressBar exposing (progressBar)
import UI.ToString exposing (bytesToString, secondsToTimeNotation)
import Game.Data as Game
import Game.Servers.Models exposing (Server)
import Game.Servers.Filesystem.Models as Filesystem exposing (..)
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
    text <|
        case ver of
            FileVersionNumber pure ->
                toString pure

            NoVersion ->
                "N/V"


moduleVerToText : ModuleVersion -> Html Msg
moduleVerToText ver =
    ver
        |> toString
        |> text


sizeToText : FileSize -> Html Msg
sizeToText size =
    text <|
        case size of
            FileSizeNumber pure ->
                bytesToString (toFloat pure)

            NoSize ->
                "N/S"


module_ : FileID -> FileModule -> Html Msg
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


moduleList : FileID -> List FileModule -> List (Html Msg)
moduleList fileID acts =
    List.map (module_ fileID) acts


indvidualEntryName : File -> String
indvidualEntryName file =
    case file of
        StdFile _ ->
            getFileName file

        Folder data ->
            data.name


treeEntry : Server -> File -> Html Msg
treeEntry server file =
    let
        icon =
            span [ class [ NavIcon, entryIcon file ] ] []

        label =
            span [] [ text <| indvidualEntryName file ]
    in
        case file of
            Folder data ->
                div
                    [ class [ NavEntry, EntryDir, EntryExpanded ]
                    , menuTreeDir data.id
                    , file |> getAbsolutePath |> GoPath |> onClick
                    ]
                    [ div
                        [ class [ EntryView ] ]
                        [ icon, label ]
                    , div
                        [ class [ EntryChilds ] ]
                        (file |> getAbsolutePath |> pathInterpret |> treeEntryPath server)
                    ]

            StdFile prop ->
                div
                    [ class [ NavEntry, EntryArchive ]
                    , menuTreeArchive prop.id
                    ]
                    [ icon, label ]


treeEntryPath : Server -> SmartPath -> List (Html Msg)
treeEntryPath server path =
    path
        |> pathToString
        |> resolvePath server
        |> List.map (treeEntry server)


detailedEntry : File -> Html Msg
detailedEntry file =
    case file of
        Folder data ->
            div
                [ class [ CntListEntry, EntryDir ]
                , menuMainDir data.id
                , file |> getAbsolutePath |> GoPath |> onClick
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
                        , span [] [ text <| indvidualEntryName file ]
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
                                , span [] [ text <| indvidualEntryName file ]
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


detailedEntryList : List File -> List (Html Msg)
detailedEntryList list =
    List.map
        detailedEntry
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


explorerColumn : SmartPath -> Server -> Html Msg
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


breadcrumbItem : FilePath -> String -> Html Msg
breadcrumbItem path label =
    span
        [ class [ BreadcrumbItem ]
        , onClick <| GoPath path
        ]
        [ text label ]


breadcrumbFold : String -> ( List (Html Msg), String ) -> ( List (Html Msg), String )
breadcrumbFold item ( htmlElems, pathAcu ) =
    if (String.length item) < 1 then
        ( htmlElems, pathAcu )
    else
        let
            fullPath =
                pathAcu ++ "/" ++ item

            newElems =
                item
                    |> breadcrumbItem fullPath
                    |> (flip (::)) htmlElems
        in
            ( newElems, fullPath )


breadcrumb : SmartPath -> Html Msg
breadcrumb path =
    path
        |> pathFuckStart
        |> List.foldl breadcrumbFold ( [], "" )
        |> Tuple.first
        |> List.reverse
        |> (::) (breadcrumbItem "/" "DISK")
        |> div [ class [ LocBar ] ]


explorerMainHeader : SmartPath -> Html Msg
explorerMainHeader path =
    div
        [ class [ ContentHeader ] ]
        [ breadcrumb path
        , div
            [ class [ ActBtns ] ]
            [ span
                [ class [ GoUpBtn ]
                , path |> pathGoUp |> pathToString |> GoPath |> onClick
                ]
                []
            , span
                [ class [ DocBtn, NewBtn ]
                , CreatingFile "" |> UpdateEditing |> onClick
                ]
                []
            , span
                [ class [ DirBtn, NewBtn ]
                , CreatingPath "" |> UpdateEditing |> onClick
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
                [ input [ value nowName ] [], button [] [ text "CREATE FILE" ] ]

            CreatingPath nowName ->
                [ input [ value nowName ] [], button [] [ text "CREATE PATH" ] ]

            Moving fileID ->
                [ text "Moving ", text fileID, text ".", button [] [ text "MOVE HERE" ] ]

            Renaming fileID newName ->
                [ input [ value newName ] [], button [] [ text "RENAME" ] ]


explorerMain : EditingStatus -> SmartPath -> Server -> Html Msg
explorerMain editing path server =
    div
        [ class
            [ Content ]
        ]
        [ explorerMainHeader path
        , explorerMainDinamycContent editing
        , path
            |> pathToString
            |> resolvePath server
            |> detailedEntryList
            |> div [ class [ ContentList ] ]
        ]


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    let
        nowPath =
            app.path |> pathInterpret
    in
        div [ class [ Window ] ]
            [ explorerColumn (Relative [ "%favorites" ]) data.server
            , explorerMain app.editing nowPath data.server
            , menuView model
            ]
