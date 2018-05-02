module Apps.Explorer.View exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (value, attribute)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers
import ContextMenu
import Utils.Maybe as Maybe
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Shared as Servers exposing (CId)
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Filesystem.Shared as Filesystem
import Apps.Explorer.Config exposing (..)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Models exposing (..)
import Apps.Explorer.Resources exposing (Classes(..), prefix, idAttrKey)
import UI.Elements.Modal exposing (modalPickStorage)
import UI.Elements.ProgressBar exposing (progressBar)
import UI.ToString exposing (bytesToString, secondsToTimeNotation)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view ({ activeServer } as config) ({ editing, path, modal } as model) =
    div [ class [ Window ] ]
        [ explorerColumn config activeServer model
        , explorerMain config editing path activeServer model
        , modals config modal
        ]


modals : Config msg -> Maybe ModalAction -> Html msg
modals config modal =
    case modal of
        Nothing ->
            text ""

        Just (ForDownload target file) ->
            modalPickStorage ((Tuple.second config.activeGateway).storages)
                (Maybe.map (flip (config.onDownloadFile target) file)
                    >> Maybe.withDefault (config.toMsg (EnterModal Nothing))
                )


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


moduleList : Config msg -> Filesystem.Id -> Filesystem.Type -> List (Html msg)
moduleList config fileID type_ =
    List.map (module_ config fileID type_) <|
        modulesOfType type_


module_ :
    Config msg
    -> Filesystem.Id
    -> Filesystem.Type
    -> ( String, Filesystem.Version, Classes )
    -> Html msg
module_ config fileID type_ ( name, version, iconClass ) =
    div [ menuActiveAction config fileID ]
        [ span [ class [ iconClass ] ] []
        , span [] [ text name ]
        , span [] [ moduleVerToText version ]
        , span [] []
        ]


menuActiveAction : Config msg -> Filesystem.Id -> Attribute msg
menuActiveAction { menuAttr } _ =
    --TODO : ( ContextMenu.item "Run", onFileRun id )
    menuAttr []


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


treeEntry : Config msg -> Server -> Filesystem.Entry -> Model -> Html msg
treeEntry ({ toMsg } as config) server file model =
    let
        icon =
            span [ class [ NavIcon, entryIcon file ] ] []

        label =
            span [] [ text <| Filesystem.getEntryName file ]

        storage =
            getStorage server model
    in
        case file of
            Filesystem.FileEntry id file ->
                div
                    [ class [ NavEntry, EntryArchive ]
                    , menuTreeArchive config storage ( id, file )
                    ]
                    [ icon, label ]

            Filesystem.FolderEntry path name ->
                case getFilesystem server model of
                    Just fs ->
                        let
                            fullpath =
                                Filesystem.appendPath name path
                        in
                            div
                                [ class [ NavEntry, EntryDir, EntryExpanded ]
                                , menuTreeDir config fullpath
                                , onClick <| toMsg <| GoPath fullpath
                                ]
                                [ div
                                    [ class [ EntryView ] ]
                                    [ icon, label ]
                                , div [ class [ EntryChilds ] ] <|
                                    treeEntryPath config server fullpath model
                                ]

                    Nothing ->
                        text ""


treeEntryPath : Config msg -> Server -> Filesystem.Path -> Model -> List (Html msg)
treeEntryPath config server path model =
    model
        |> resolvePath path server
        |> List.map (flip (treeEntry config server) model)


detailedEntry :
    Config msg
    -> Server
    -> Filesystem.Entry
    -> Model
    -> Html msg
detailedEntry config server entry model =
    case entry of
        Filesystem.FolderEntry path name ->
            detailedFolder config path name server model

        Filesystem.FileEntry id file ->
            let
                storage =
                    getStorage server model
            in
                case Filesystem.getType file of
                    Filesystem.Text ->
                        detailedTextFile config storage entry ( id, file )

                    _ ->
                        detailedGenericArchive config storage entry ( id, file )


detailedFolder : Config msg -> Filesystem.Path -> Filesystem.Name -> Server -> Model -> Html msg
detailedFolder config path name server model =
    case getFilesystem server model of
        Just fs ->
            let
                storage =
                    getStorage server model

                path_ =
                    Filesystem.appendPath name path
            in
                div
                    [ class [ CntListEntry, EntryDir ]
                    , menuMainDir config path_
                    , onClick <| config.toMsg <| GoPath path_
                    , idAttr <| Filesystem.joinPath path_
                    ]
                    [ span [ class [ DirIcon ] ] []
                    , span [] [ text name ]
                    ]

        Nothing ->
            text ""


detailedTextFile :
    Config msg
    -> Servers.StorageId
    -> Filesystem.Entry
    -> ( Filesystem.Id, Filesystem.File )
    -> Html msg
detailedTextFile config storage entry (( id, file ) as fileEntry) =
    div
        [ class [ CntListEntry, EntryArchive ]
        , menuMainArchive config storage fileEntry
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


detailedGenericArchive :
    Config msg
    -> Servers.StorageId
    -> Filesystem.Entry
    -> ( Filesystem.Id, Filesystem.File )
    -> Html msg
detailedGenericArchive config storage entry (( id, file ) as fileEntry) =
    let
        baseEntry =
            div
                [ class [ CntListEntry, EntryArchive ]
                , menuExecutable config storage fileEntry
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
                    moduleList config id <|
                        Filesystem.getType file
                ]
        else
            baseEntry


detailedEntryList :
    Config msg
    -> Server
    -> List Filesystem.Entry
    -> Model
    -> List (Html msg)
detailedEntryList config server list model =
    List.map (flip (detailedEntry config server) model) list


menuTreeArchive :
    Config msg
    -> Servers.StorageId
    -> ( Filesystem.Id, Filesystem.File )
    -> Attribute msg
menuTreeArchive =
    menuMainArchive


menuTreeDir : Config msg -> Filesystem.Path -> Attribute msg
menuTreeDir =
    menuMainDir


menuMainDir : Config msg -> Filesystem.Path -> Attribute msg
menuMainDir { menuAttr, toMsg } fullPath =
    menuAttr
        [ [ ( ContextMenu.item "Enter", toMsg <| GoPath fullPath ) ]
        , [ ( ContextMenu.item "Rename", toMsg <| EnterRenameDir fullPath ) ]
        ]


menuMainArchive :
    Config msg
    -> Servers.StorageId
    -> ( Filesystem.Id, Filesystem.File )
    -> Attribute msg
menuMainArchive ({ menuAttr } as config) storage (( id, _ ) as fileEntry) =
    let
        activeCId =
            Just <| Tuple.first config.activeServer

        contextUnique =
            if (config.endpointCId == activeCId) then
                [ ( ContextMenu.item "Download", downloadAction config fileEntry ) ]
            else
                [ ( ContextMenu.item "Upload", uploadAction config fileEntry storage ) ]

        common =
            [ ( ContextMenu.item "Rename", config.toMsg <| EnterRename id )
            , ( ContextMenu.item "Move", config.toMsg <| UpdateEditing (Moving id) )
            , ( ContextMenu.item "Delete", config.onDeleteFile storage id )
            ]
    in
        menuAttr [ common, contextUnique ]


menuExecutable :
    Config msg
    -> Servers.StorageId
    -> ( Filesystem.Id, Filesystem.File )
    -> Attribute msg
menuExecutable =
    menuMainArchive


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


explorerColumn : Config msg -> ( CId, Server ) -> Model -> Html msg
explorerColumn config ( _, { storages, mainStorage } ) model =
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
storageTreeEntry { toMsg } mainStorage storageId { name } acu =
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
            , onClick <| toMsg <| GoStorage storageId
            ]
            [ icon, label ]
        )
            :: acu


breadcrumbItem : Config msg -> Filesystem.Path -> String -> Html msg
breadcrumbItem { toMsg } path label =
    span
        [ class [ BreadcrumbItem ]
        , onClick <| toMsg <| GoPath path
        ]
        [ text label ]


breadcrumbFold :
    Config msg
    -> Filesystem.Name
    -> ( List (Html msg), Filesystem.Path )
    -> ( List (Html msg), Filesystem.Path )
breadcrumbFold config item ( htmlElems, pathAcu ) =
    if (String.length item) < 1 then
        ( htmlElems, pathAcu )
    else
        let
            fullPath =
                Filesystem.appendPath item pathAcu

            newElems =
                item
                    |> breadcrumbItem config fullPath
                    |> (flip (::)) htmlElems
        in
            ( newElems, fullPath )


breadcrumb : Config msg -> Filesystem.Path -> Html msg
breadcrumb config path =
    path
        |> List.foldl (breadcrumbFold config) ( [], [ "" ] )
        |> Tuple.first
        |> List.reverse
        |> (::) (breadcrumbItem config [ "" ] "DISK")
        |> div [ class [ LocBar ] ]


explorerMainHeader : Config msg -> Filesystem.Path -> Html msg
explorerMainHeader ({ toMsg } as config) path =
    div
        [ class [ ContentHeader ] ]
        [ breadcrumb config path
        , div
            [ class [ ActBtns ] ]
            [ span
                [ class [ GoUpBtn ]
                , onClick <| toMsg <| GoPath (Filesystem.parentPath path)
                ]
                []
            , span
                [ class [ DocBtn, NewBtn ]
                , onClick <| toMsg <| UpdateEditing (CreatingFile "")
                ]
                []
            , span
                [ class [ DirBtn, NewBtn ]
                , onClick <| toMsg <| UpdateEditing (CreatingPath "")
                ]
                []
            ]
        ]


explorerMainDinamycContent : Config msg -> EditingStatus -> Html msg
explorerMainDinamycContent { toMsg } editing =
    div [] <|
        case editing of
            NotEditing ->
                []

            CreatingFile nowName ->
                [ input
                    [ value nowName
                    , onInput <| (CreatingFile >> UpdateEditing >> toMsg)
                    ]
                    []
                , button [ onClick <| toMsg ApplyEdit ] [ text "CREATE FILE" ]
                ]

            CreatingPath nowName ->
                [ input
                    [ value nowName
                    , onInput <| (CreatingPath >> UpdateEditing >> toMsg)
                    ]
                    []
                , button [ onClick <| toMsg ApplyEdit ] [ text "CREATE PATH" ]
                ]

            Moving fileID ->
                [ button [ onClick <| toMsg ApplyEdit ] [ text "MOVE HERE" ]
                ]

            Renaming fileID newName ->
                [ input
                    [ value newName
                    , onInput <| (Renaming fileID >> UpdateEditing >> toMsg)
                    ]
                    []
                , button [ onClick <| toMsg ApplyEdit ] [ text "RENAME" ]
                ]

            -- TODO: add folder features
            _ ->
                []


explorerMain :
    Config msg
    -> EditingStatus
    -> Filesystem.Path
    -> ( CId, Server )
    -> Model
    -> Html msg
explorerMain config editing path ( _, server ) model =
    div
        [ class
            [ Content ]
        ]
        [ explorerMainHeader config path
        , explorerMainDinamycContent config editing
        , model
            |> resolvePath path server
            |> flip (detailedEntryList config server) model
            |> div [ class [ ContentList ] ]
        ]


uploadAction :
    Config msg
    -> ( Filesystem.Id, Filesystem.File )
    -> Servers.StorageId
    -> msg
uploadAction ({ onUploadFile, batchMsg } as config) fileEntry storage =
    let
        fs =
            config.getFilesystem storage
    in
        case Maybe.uncurry config.endpointCId config.endpointMainStorage of
            Just ( target, storageId ) ->
                onUploadFile target storageId fileEntry

            Nothing ->
                batchMsg []


downloadAction :
    Config msg
    -> ( Filesystem.Id, Filesystem.File )
    -> msg
downloadAction { activeServer, toMsg } fileEntry =
    let
        target =
            Servers.getActiveNIP (Tuple.second activeServer)
    in
        toMsg <| EnterModal <| Just <| ForDownload target fileEntry
