module Apps.Explorer.View exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (value, attribute)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers
import UI.Widgets.ProgressBar exposing (progressBar)
import UI.ToString exposing (bytesToString, secondsToTimeNotation)
import Game.Data as Game
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Shared as Servers
import Game.Servers.Filesystem.Shared as Filesystem
import Apps.Explorer.Config exposing (..)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Models exposing (..)
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
import Apps.Explorer.Resources exposing (Classes(..), prefix, idAttrKey)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config ({ editing, path } as model) =
    let
        server =
            config.activeCId
    in
        div [ class [ Window ] ]
            [ explorerColumn config server model
            , explorerMain config editing path server model
            , menuView config model
            ]


idAttr : String -> Attribute msg
idAttr =
    attribute idAttrKey


entryIcon : Filesystem.Entry -> Classes
entryIcon entry =
    if Filesystem.isFolderEntry entry then
        CasedDirIcon
    else
        case Maybe.map Filesystem.toFile <| Filesystem.toFileEntry entry of
            Just file ->
                case Filesystem.getType file of
                    Filesystem.Cracker _ ->
                        VirusIcon

                    Filesystem.Firewall _ ->
                        FirewallIcon

                    _ ->
                        GenericArchiveIcon

            Nothing ->
                GenericArchiveIcon


fileVerToText : Maybe Filesystem.Version -> Html msg
fileVerToText ver =
    ver
        |> Maybe.map toString
        |> Maybe.withDefault "N/D"
        |> text


moduleVerToText : Filesystem.Version -> Html msg
moduleVerToText ver =
    ver
        |> toString
        |> text


sizeToText : Filesystem.Size -> Html msg
sizeToText size =
    size
        |> toFloat
        |> bytesToString
        |> text


module_ :
    Filesystem.Id
    -> Filesystem.Type
    -> ( String, Filesystem.Version, Classes )
    -> Html msg
module_ fileID type_ ( name, version, iconClass ) =
    div [ menuActiveAction fileID ]
        [ span [ class [ iconClass ] ] []
        , span [] [ text name ]
        , span [] [ moduleVerToText version ]
        , span [] []
        ]


moduleList : Filesystem.Id -> Filesystem.Type -> List (Html msg)
moduleList fileID type_ =
    List.map (module_ fileID type_) <|
        modulesOfType type_


modulesOfType : Filesystem.Type -> List ( String, Filesystem.Version, Classes )
modulesOfType type_ =
    List.map (\( a, b, c ) -> ( a, Filesystem.getModuleVersion b, c )) <|
        case type_ of
            Filesystem.Cracker { bruteForce, overFlow } ->
                [ ( "Bruteforce", bruteForce, ActiveIcon )
                , ( "Overflow", overFlow, ActiveIcon )
                ]

            Filesystem.Firewall { active, passive } ->
                [ ( "Active", active, ActiveIcon )
                , ( "Passive", passive, PassiveIcon )
                ]

            Filesystem.Exploit { ftp, ssh } ->
                [ ( "FTP", ftp, ActiveIcon )
                , ( "SSH", ssh, ActiveIcon )
                ]

            Filesystem.Hasher { password } ->
                [ ( "Password", password, ActiveIcon ) ]

            Filesystem.LogForger { create, edit } ->
                [ ( "Create", create, ActiveIcon )
                , ( "Edit", edit, ActiveIcon )
                ]

            Filesystem.LogRecover { recover } ->
                [ ( "Recover", recover, ActiveIcon ) ]

            Filesystem.Encryptor { file, log, connection, process } ->
                [ ( "File", file, ActiveIcon )
                , ( "Log", log, ActiveIcon )
                , ( "Connections", connection, ActiveIcon )
                , ( "Process", process, ActiveIcon )
                ]

            Filesystem.Decryptor { file, log, connection, process } ->
                [ ( "File", file, ActiveIcon )
                , ( "Log", log, ActiveIcon )
                , ( "Connections", connection, ActiveIcon )
                , ( "Process", process, ActiveIcon )
                ]

            Filesystem.AnyMap { geo, net } ->
                [ ( "Geo", geo, ActiveIcon )
                , ( "Net", net, ActiveIcon )
                ]

            _ ->
                []


treeEntry : Server -> Filesystem.Entry -> Model -> Html msg
treeEntry server file model =
    let
        icon =
            span [ class [ NavIcon, entryIcon file ] ] []

        label =
            span [] [ text <| Filesystem.getEntryName file ]
    in
        -- forced to leak implementation details
        case file of
            Filesystem.FolderEntry path name ->
                let
                    fullpath =
                        Filesystem.appendPath name path
                in
                    case getFilesystem server model of
                        Just fs ->
                            div
                                [ class [ NavEntry, EntryDir, EntryExpanded ]
                                , menuTreeDir fullpath
                                , onClick <| GoPath fullpath
                                ]
                                [ div
                                    [ class [ EntryView ] ]
                                    [ icon, label ]
                                , div [ class [ EntryChilds ] ] <|
                                    treeEntryPath server fullpath model
                                ]

                        Nothing ->
                            div [] []

            Filesystem.FileEntry id file ->
                div
                    [ class [ NavEntry, EntryArchive ]
                    , menuTreeArchive id
                    ]
                    [ icon, label ]


treeEntryPath : Server -> Filesystem.Path -> Model -> List (Html msg)
treeEntryPath server path model =
    model
        |> resolvePath path server
        |> List.map (flip (treeEntry server) model)


detailedEntry : Config msg -> Server -> Filesystem.Entry -> Model -> Html msg
detailedEntry config server entry model =
    case entry of
        Filesystem.FolderEntry path name ->
            let
                path_ =
                    Filesystem.appendPath name path
            in
                case getFilesystem server model of
                    Just fs ->
                        div
                            [ class [ CntListEntry, EntryDir ]
                            , menuMainDir path_
                            , onClick <| config.toMsg <| GoPath path_
                            , idAttr <| Filesystem.joinPath path_
                            ]
                            [ span [ class [ DirIcon ] ] []
                            , span [] [ text name ]
                            ]

                    Nothing ->
                        div [] []

        Filesystem.FileEntry id file ->
            case Filesystem.getType file of
                Filesystem.Text ->
                    div
                        [ class [ CntListEntry, EntryArchive ]
                        , menuMainArchive id
                        , idAttr id
                        ]
                        [ span [ class [ entryIcon entry ] ] []
                        , span [] [ text <| Filesystem.getName file ]
                        , span []
                            [ fileVerToText <|
                                Filesystem.getMeanVersion file
                            ]
                        , span []
                            [ sizeToText <|
                                Filesystem.getSize file
                            ]
                        ]

                _ ->
                    let
                        baseEntry =
                            div
                                [ class [ CntListEntry, EntryArchive ]
                                , menuExecutable id
                                , idAttr id
                                ]
                                [ span [ class [ entryIcon entry ] ] []
                                , span [] [ text <| Filesystem.getName file ]
                                , span []
                                    [ fileVerToText <|
                                        Filesystem.getMeanVersion file
                                    ]
                                , span []
                                    [ sizeToText <|
                                        Filesystem.getSize file
                                    ]
                                ]
                    in
                        if Filesystem.hasModules file then
                            div [ class [ CntListContainer ] ]
                                [ baseEntry
                                , div [ class [ CntListChilds ] ] <|
                                    moduleList id <|
                                        Filesystem.getType file
                                ]
                        else
                            baseEntry


detailedEntryList : Config msg -> Server -> List Filesystem.Entry -> Model -> List (Html msg)
detailedEntryList config server list model =
    List.map (flip (detailedEntry config server) model) list


usage : Float -> Float -> Html msg
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


explorerColumn : Config msg -> Server -> Model -> Html msg
explorerColumn config { storages, mainStorage } model =
    div
        [ class [ Nav ]
        ]
        [ Dict.foldl (storageTreeEntry config mainStorage) [] storages
            |> div [ class [ NavTree ] ]
        , usage 256000000 1024000000
        ]


storageTreeEntry :
    Config msg
    -> Servers.StorageId
    -> Servers.StorageId
    -> Servers.Storage
    -> List (Html msg)
    -> List (Html msg)
storageTreeEntry config mainStorage storageId { name } acu =
    let
        activeAttributeValue =
            if (mainStorage == storageId) then
                "master"
            else
                "slave"

        activeAttribute =
            attribute "ide-flag" activeAttributeValue

        icon =
            span [ class [ NavIcon, StorageIcon ], activeAttribute ] []

        label =
            span [] [ text name ]
    in
        (div
            [ class [ NavEntry, EntryArchive ]
            , onClick <| config.toMsg <| GoStorage storageId
            ]
            [ icon, label ]
        )
            :: acu


breadcrumbItem : Config msg -> Filesystem.Path -> String -> Html msg
breadcrumbItem config path label =
    span
        [ class [ BreadcrumbItem ]
        , onClick <| config.toMsg <| GoPath path
        ]
        [ text label ]


breadcrumbFold :
    Filesystem.Name
    -> ( List (Html msg), Filesystem.Path )
    -> ( List (Html msg), Filesystem.Path )
breadcrumbFold item ( htmlElems, pathAcu ) =
    if (String.length item) < 1 then
        ( htmlElems, pathAcu )
    else
        let
            fullPath =
                Filesystem.appendPath item pathAcu

            newElems =
                item
                    |> breadcrumbItem fullPath
                    |> (flip (::)) htmlElems
        in
            ( newElems, fullPath )


breadcrumb : Filesystem.Path -> Html msg
breadcrumb path =
    path
        |> List.foldl breadcrumbFold ( [], [ "" ] )
        |> Tuple.first
        |> List.reverse
        |> (::) (breadcrumbItem [ "" ] "DISK")
        |> div [ class [ LocBar ] ]


explorerMainHeader : Config msg -> Filesystem.Path -> Html msg
explorerMainHeader config path =
    div
        [ class [ ContentHeader ] ]
        [ breadcrumb path
        , div
            [ class [ ActBtns ] ]
            [ span
                [ class [ GoUpBtn ]
                , onClick <| config.toMsg <| GoPath <| Filesystem.parentPath path
                ]
                []
            , span
                [ class [ DocBtn, NewBtn ]
                , onClick <| config.toMsg <| UpdateEditing <| CreatingFile ""
                ]
                []
            , span
                [ class [ DirBtn, NewBtn ]
                , onClick <| config.toMsg <| UpdateEditing <| CreatingPath ""
                ]
                []
            ]
        ]


explorerMainDinamycContent : Config msg -> EditingStatus -> Html msg
explorerMainDinamycContent config editing =
    div [] <|
        case editing of
            NotEditing ->
                []

            CreatingFile nowName ->
                [ input
                    [ value nowName
                    , onInput <| config.toMsg <| CreatingFile >> UpdateEditing
                    ]
                    []
                , button [ onClick <| config.toMsg ApplyEdit ] [ text "CREATE FILE" ]
                ]

            CreatingPath nowName ->
                [ input
                    [ value nowName
                    , onInput <| config.toMsg <| CreatingPath >> UpdateEditing
                    ]
                    []
                , button [ onClick <| config.toMsg ApplyEdit ] [ text "CREATE PATH" ]
                ]

            Moving fileID ->
                [ button [ onClick <| config.toMsg ApplyEdit ] [ text "MOVE HERE" ]
                ]

            Renaming fileID newName ->
                [ input
                    [ value newName
                    , onInput <| config.toMsg <| (Renaming fileID) >> UpdateEditing
                    ]
                    []
                , button [ onClick <| config.toMsg ApplyEdit ] [ text "RENAME" ]
                ]

            -- TODO: add folder features
            _ ->
                []


explorerMain :
    Config msg
    -> EditingStatus
    -> Filesystem.Path
    -> Server
    -> Model
    -> Html msg
explorerMain config editing path server model =
    div
        [ class
            [ Content ]
        ]
        [ explorerMainHeader config path
        , explorerMainDinamycContent config editing
        , model
            |> resolvePath path server
            |> flip (detailedEntryList server) model
            |> div [ class [ ContentList ] ]
        ]
