module Game.Servers.Filesystem.Update exposing (update, bootstrap)

import Json.Decode exposing (Value)
import Utils.Update as Update
import Requests.Requests as Requests
import Requests.Types exposing (Code(..))
import Game.Models as Game
import Game.Servers.Shared exposing (..)
import Game.Servers.Filesystem.Messages exposing (Msg(..), RequestMsg(..))
import Game.Servers.Filesystem.Shared exposing (..)
import Game.Servers.Filesystem.Models exposing (..)
import Game.Servers.Filesystem.Requests.Delete as RqDelete
import Game.Servers.Filesystem.Requests.Move as RqMove
import Game.Servers.Filesystem.Requests.Rename as RqRename
import Game.Servers.Filesystem.Requests.Create as RqCreate
import Game.Servers.Filesystem.Requests.Index as RqIndex exposing (Index)
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse =
    ( Filesystem, Cmd Msg, Dispatch )


update :
    Game.Model
    -> ID
    -> Msg
    -> Filesystem
    -> UpdateResponse
update game serverId msg model =
    case msg of
        Delete fileId ->
            delete fileId game serverId model

        CreateTextFile path ->
            createTextFile path
                (toString game.meta.lastTick)
                game
                serverId
                model

        CreateEmptyDir path ->
            createEmptyDir path
                (toString game.meta.lastTick)
                game
                serverId
                model

        Move fileId newLocation ->
            move fileId newLocation game serverId model

        Rename fileId newBaseName ->
            rename fileId newBaseName game serverId model

        Request (IndexRequest ( code, value )) ->
            case code of
                OkCode ->
                    Update.fromModel <| bootstrap value model

                _ ->
                    Update.fromModel model

        Request _ ->
            Update.fromModel model


bootstrap : Value -> Filesystem -> Filesystem
bootstrap value _ =
    value
        |> RqIndex.decoder
        |> Requests.report
        |> List.foldl (convEntry RootRef) initialModel



-- INTERNALS


convEntry : ParentReference -> RqIndex.Entry -> Filesystem -> Filesystem
convEntry parentRef src filesystem =
    case src of
        RqIndex.FileEntry data ->
            addEntry
                (FileEntry
                    { id = data.id
                    , name = data.name
                    , parent = parentRef
                    , extension = data.extension
                    , version = data.version
                    , size = data.size
                    , modules = data.modules
                    }
                )
                filesystem

        RqIndex.FolderEntry data ->
            let
                meAdded =
                    addEntry
                        (FolderEntry { id = data.id, name = data.name, parent = parentRef })
                        filesystem

                parentRef =
                    NodeRef data.id
            in
                List.foldl
                    (convEntry parentRef)
                    meAdded
                    data.children


delete : FileID -> Game.Model -> ID -> Filesystem -> UpdateResponse
delete fileId game serverId model =
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


createTextFile : FilePath -> FileID -> Game.Model -> ID -> Filesystem -> UpdateResponse
createTextFile ( fileLocation, fileBaseName ) fileId game serverId model =
    let
        model_ =
            model
                |> locationToParentRef fileLocation
                |> Maybe.map
                    (\path ->
                        FileEntry
                            { id =
                                "tempID"
                                    ++ "_TXT_"
                                    ++ (fileBaseName ++ "_")
                                    ++ fileId
                            , name = fileBaseName
                            , extension = "txt"
                            , version = Nothing
                            , size = Just 0
                            , parent = path
                            , modules = []
                            }
                    )
                |> Maybe.map (\e -> addEntry e model)
                |> Maybe.withDefault model

        serverCmd =
            RqCreate.request "txt" fileBaseName fileLocation serverId game
    in
        ( model_, serverCmd, Dispatch.none )


createEmptyDir : FilePath -> FileID -> Game.Model -> ID -> Filesystem -> UpdateResponse
createEmptyDir ( fileLocation, fileName ) fileId game serverId model =
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


move : FileID -> Location -> Game.Model -> ID -> Filesystem -> UpdateResponse
move fileId newLocation game serverId model =
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


rename : FileID -> String -> Game.Model -> ID -> Filesystem -> UpdateResponse
rename fileId newBaseName game serverId model =
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
