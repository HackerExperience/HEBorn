module Game.Servers.Filesystem.Update exposing (update, bootstrap)

import Json.Decode exposing (Value, decodeValue)
import Utils.Update as Update
import Requests.Requests as Requests
import Events.Servers.Filesystem as Index exposing (apply)
import Game.Models as Game
import Game.Servers.Shared as Servers
import Game.Servers.Filesystem.Messages exposing (Msg(..), RequestMsg(..))
import Game.Servers.Filesystem.Shared exposing (..)
import Game.Servers.Filesystem.Models exposing (..)
import Game.Servers.Filesystem.Requests exposing (..)
import Game.Servers.Filesystem.Requests.Delete as RqDelete
import Game.Servers.Filesystem.Requests.Move as RqMove
import Game.Servers.Filesystem.Requests.Rename as RqRename
import Game.Servers.Filesystem.Requests.Create as RqCreate
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse =
    ( Filesystem, Cmd Msg, Dispatch )


update :
    Game.Model
    -> Servers.ID
    -> Msg
    -> Filesystem
    -> UpdateResponse
update game serverId msg model =
    case msg of
        Delete fileId ->
            onDelete game serverId fileId model

        CreateTextFile path ->
            onCreateTextFile game
                serverId
                (toString game.meta.lastTick)
                path
                model

        CreateEmptyDir path ->
            onEmptyDir game serverId (toString game.meta.lastTick) path model

        Move fileId newLocation ->
            onMove game serverId fileId newLocation model

        Rename fileId newBaseName ->
            onRename game serverId fileId newBaseName model

        Request request ->
            Update.fromModel model


bootstrap : Value -> Filesystem -> Filesystem
bootstrap json model =
    decodeValue Index.decoder json
        |> Requests.report
        |> Maybe.map (apply model)
        |> Maybe.withDefault model


onDelete : Game.Model -> Servers.ID -> FileID -> Filesystem -> UpdateResponse
onDelete game serverId fileId model =
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
            RqDelete.request fileId serverId game
    in
        ( model_, serverCmd, Dispatch.none )


onCreateTextFile :
    Game.Model
    -> Servers.ID
    -> FileID
    -> FilePath
    -> Filesystem
    -> UpdateResponse
onCreateTextFile game serverId fileId ( fileLocation, fileBaseName ) model =
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
                        RqCreate.request "txt"
                            fileBaseName
                            fileLocation
                            serverId
                            game
                in
                    ( model_, cmd, Dispatch.none )

            Nothing ->
                Update.fromModel model


onEmptyDir :
    Game.Model
    -> Servers.ID
    -> FileID
    -> FilePath
    -> Filesystem
    -> UpdateResponse
onEmptyDir game serverId fileId ( fileLocation, fileName ) model =
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
            RqCreate.request "/" fileName fileLocation serverId game
    in
        ( model_, serverCmd, Dispatch.none )


onMove :
    Game.Model
    -> Servers.ID
    -> FileID
    -> Location
    -> Filesystem
    -> UpdateResponse
onMove game serverId fileId newLocation model =
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
            RqMove.request newLocation fileId serverId game
    in
        ( model_, serverCmd, Dispatch.none )


onRename :
    Game.Model
    -> Servers.ID
    -> FileID
    -> String
    -> Filesystem
    -> UpdateResponse
onRename game serverId fileId newBaseName model =
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
            RqRename.request newBaseName fileId serverId game
    in
        ( model_, serverCmd, Dispatch.none )


onRequest :
    Game.Model
    -> Servers.ID
    -> Maybe Response
    -> Filesystem
    -> UpdateResponse
onRequest game serverId response model =
    Update.fromModel model
