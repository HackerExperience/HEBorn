module Game.Servers.Filesystem.Update exposing (update, bootstrap)

import Json.Decode exposing (Value, decodeValue)
import Utils.Update as Update
import Requests.Requests as Requests
import Game.Models as Game
import Game.Servers.Filesystem.Messages exposing (..)
import Game.Servers.Filesystem.Shared exposing (..)
import Game.Servers.Filesystem.Models exposing (..)
import Game.Servers.Filesystem.Requests exposing (..)
import Game.Servers.Filesystem.Requests.Sync as Sync
import Game.Servers.Filesystem.Requests.Delete as Delete
import Game.Servers.Filesystem.Requests.Move as Move
import Game.Servers.Filesystem.Requests.Rename as Rename
import Game.Servers.Filesystem.Requests.Create as Create
import Game.Servers.Shared exposing (CId)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Network.Types exposing (NIP)


type alias UpdateResponse =
    ( Filesystem, Cmd Msg, Dispatch )


update :
    Game.Model
    -> CId
    -> Msg
    -> Filesystem
    -> UpdateResponse
update game cid msg model =
    case msg of
        Delete fileId ->
            onDelete game cid fileId model

        CreateTextFile path ->
            onCreateTextFile game
                cid
                (toString game.meta.lastTick)
                path
                model

        CreateEmptyDir path ->
            onEmptyDir game cid (toString game.meta.lastTick) path model

        Move fileId newLocation ->
            onMove game cid fileId newLocation model

        Rename fileId newBaseName ->
            onRename game cid fileId newBaseName model

        Request request ->
            onRequest game cid (receive request) model


bootstrap : Value -> Filesystem -> Filesystem
bootstrap json model =
    decodeValue Sync.decoder json
        |> Requests.report
        |> Maybe.map (apply model)
        |> Maybe.withDefault model



-- internals


onDelete : Game.Model -> CId -> FileID -> Filesystem -> UpdateResponse
onDelete game cid fileId model =
    let
        file =
            getEntry fileId model

        model_ =
            case file of
                Just file ->
                    deleteEntry file model

                Nothing ->
                    model

        serverCmd =
            Delete.request fileId cid game
    in
        ( model_, serverCmd, Dispatch.none )


onCreateTextFile :
    Game.Model
    -> CId
    -> FileID
    -> FilePath
    -> Filesystem
    -> UpdateResponse
onCreateTextFile game cid fileId ( fileLocation, fileBaseName ) model =
    let
        toFileEntry path =
            FileEntry
                { id =
                    "tempID"
                        ++ "_TXT_"
                        ++ (fileBaseName)
                        ++ "_"
                        ++ fileId
                , name = fileBaseName
                , extension = "txt"
                , version = Nothing
                , size = Just 0
                , parent = path
                , mime = Text
                }

        maybeModel =
            locationToParentRef fileLocation model
                |> Maybe.map toFileEntry
                |> Maybe.map (flip addEntry model)
    in
        case maybeModel of
            Just model_ ->
                let
                    cmd =
                        Create.request "txt"
                            fileBaseName
                            fileLocation
                            cid
                            game
                in
                    ( model_, cmd, Dispatch.none )

            Nothing ->
                Update.fromModel model


onEmptyDir :
    Game.Model
    -> CId
    -> FileID
    -> FilePath
    -> Filesystem
    -> UpdateResponse
onEmptyDir game cid fileId ( fileLocation, fileName ) model =
    let
        model_ =
            model
                |> locationToParentRef fileLocation
                |> Maybe.map
                    (\path ->
                        let
                            entry =
                                FolderEntry
                                    { id =
                                        "tempID"
                                            ++ "_DIR_"
                                            ++ (fileName ++ "_")
                                            ++ fileId
                                    , name = fileName
                                    , parent = path
                                    }
                        in
                            addEntry entry model
                    )
                |> Maybe.withDefault model

        serverCmd =
            Create.request "/" fileName fileLocation cid game
    in
        ( model_, serverCmd, Dispatch.none )


onMove :
    Game.Model
    -> CId
    -> FileID
    -> Location
    -> Filesystem
    -> UpdateResponse
onMove game cid fileId newLocation model =
    let
        model_ =
            model
                |> getEntry fileId
                |> Maybe.map
                    (\e ->
                        moveEntry
                            ( newLocation, getEntryBasename e )
                            e
                            model
                    )
                |> Maybe.withDefault model

        serverCmd =
            Move.request newLocation fileId cid game
    in
        ( model_, serverCmd, Dispatch.none )


onRename :
    Game.Model
    -> CId
    -> FileID
    -> String
    -> Filesystem
    -> UpdateResponse
onRename game cid fileId newBaseName model =
    let
        model_ =
            model
                |> getEntry fileId
                |> Maybe.map
                    (\e ->
                        moveEntry
                            ( getEntryLocation e model
                            , newBaseName
                            )
                            e
                            model
                    )
                |> Maybe.withDefault model

        serverCmd =
            Rename.request newBaseName fileId cid game
    in
        ( model_, serverCmd, Dispatch.none )


onRequest :
    Game.Model
    -> CId
    -> Maybe Response
    -> Filesystem
    -> UpdateResponse
onRequest cid game response model =
    case response of
        Just response ->
            updateRequest cid game response model

        Nothing ->
            Update.fromModel model


updateRequest :
    Game.Model
    -> CId
    -> Response
    -> Filesystem
    -> UpdateResponse
updateRequest game cid data model =
    Update.fromModel model



-- sync/bootstrap internals


apply : Filesystem -> Foreigners -> Filesystem
apply =
    let
        convEntry parentRef src filesystem =
            case src of
                ForeignFile data ->
                    let
                        entry =
                            FileEntry
                                { id = data.id
                                , name = data.name
                                , parent = parentRef
                                , extension = data.extension
                                , version = data.version
                                , size = data.size
                                , mime = data.mime
                                }
                    in
                        addEntry entry filesystem

                ForeignFolder data ->
                    let
                        entry =
                            FolderEntry
                                { id = data.id
                                , name = data.name
                                , parent = parentRef
                                }
                    in
                        List.foldl (convEntry <| NodeRef data.id)
                            (addEntry entry filesystem)
                            data.children
    in
        List.foldl (convEntry RootRef)
