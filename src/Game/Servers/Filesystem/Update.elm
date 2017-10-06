module Game.Servers.Filesystem.Update exposing (update, bootstrap)

import Json.Decode exposing (Value, decodeValue)
import Utils.Update as Update
import Requests.Requests as Requests
import Game.Models as Game
import Game.Servers.Shared as Servers
import Game.Servers.Filesystem.Messages exposing (Msg(..), RequestMsg(..))
import Game.Servers.Filesystem.Shared exposing (..)
import Game.Servers.Filesystem.Models exposing (..)
import Game.Servers.Filesystem.Requests exposing (..)
import Game.Servers.Filesystem.Requests.Sync as Sync
import Game.Servers.Filesystem.Requests.Delete as Delete
import Game.Servers.Filesystem.Requests.Move as Move
import Game.Servers.Filesystem.Requests.Rename as Rename
import Game.Servers.Filesystem.Requests.Create as Create
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Network.Types exposing (NIP)
import Decoders.Filesystem


type alias UpdateResponse =
    ( Filesystem, Cmd Msg, Dispatch )


update :
    Game.Model
    -> NIP
    -> Msg
    -> Filesystem
    -> UpdateResponse
update game nip msg model =
    case msg of
        Delete fileId ->
            onDelete game nip fileId model

        CreateTextFile path ->
            onCreateTextFile game
                nip
                (toString game.meta.lastTick)
                path
                model

        CreateEmptyDir path ->
            onEmptyDir game nip (toString game.meta.lastTick) path model

        Move fileId newLocation ->
            onMove game nip fileId newLocation model

        Rename fileId newBaseName ->
            onRename game nip fileId newBaseName model

        Request request ->
            Update.fromModel model


bootstrap : Value -> Filesystem -> Filesystem
bootstrap json model =
    decodeValue Sync.decoder json
        |> Requests.report
        |> Maybe.map (apply model)
        |> Maybe.withDefault model



-- internals


onDelete : Game.Model -> NIP -> FileID -> Filesystem -> UpdateResponse
onDelete game nip fileId model =
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
            Delete.request fileId nip game
    in
        ( model_, serverCmd, Dispatch.none )


onCreateTextFile :
    Game.Model
    -> NIP
    -> FileID
    -> FilePath
    -> Filesystem
    -> UpdateResponse
onCreateTextFile game nip fileId ( fileLocation, fileBaseName ) model =
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
                , modules = []
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
                            nip
                            game
                in
                    ( model_, cmd, Dispatch.none )

            Nothing ->
                Update.fromModel model



--Update.fromModel model


onEmptyDir :
    Game.Model
    -> NIP
    -> FileID
    -> FilePath
    -> Filesystem
    -> UpdateResponse
onEmptyDir game nip fileId ( fileLocation, fileName ) model =
    -- TODO: rewrite to be more readable
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
            Create.request "/" fileName fileLocation nip game
    in
        ( model_, serverCmd, Dispatch.none )


onMove :
    Game.Model
    -> NIP
    -> FileID
    -> Location
    -> Filesystem
    -> UpdateResponse
onMove game nip fileId newLocation model =
    -- TODO: rewrite to be more readable
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
            Move.request newLocation fileId nip game
    in
        ( model_, serverCmd, Dispatch.none )


onRename :
    Game.Model
    -> NIP
    -> FileID
    -> String
    -> Filesystem
    -> UpdateResponse
onRename game nip fileId newBaseName model =
    -- TODO: rewrite to be more readable
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
            Rename.request newBaseName fileId nip game
    in
        ( model_, serverCmd, Dispatch.none )


onRequest :
    Game.Model
    -> NIP
    -> Maybe Response
    -> Filesystem
    -> UpdateResponse
onRequest game nip response model =
    Update.fromModel model



-- sync/bootstrap internals


apply : Filesystem -> Sync.Index -> Filesystem
apply =
    let
        convEntry parentRef src filesystem =
            case src of
                Decoders.Filesystem.LeafEntry data ->
                    let
                        entry =
                            FileEntry
                                { id = data.id
                                , name = data.name
                                , parent = parentRef
                                , extension = data.extension
                                , version = data.version
                                , size = data.size
                                , modules = data.modules
                                }
                    in
                        addEntry entry filesystem

                Decoders.Filesystem.NodeEntry data ->
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
