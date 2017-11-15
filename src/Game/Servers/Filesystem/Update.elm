module Game.Servers.Filesystem.Update exposing (update)

import Json.Decode exposing (Value, decodeValue)
import Utils.Update as Update
import Requests.Requests as Requests
import Game.Models as Game
import Game.Servers.Filesystem.Messages exposing (..)
import Game.Servers.Filesystem.Models exposing (..)
import Game.Servers.Filesystem.Requests exposing (..)
import Game.Servers.Filesystem.Requests.Delete as Delete
import Game.Servers.Filesystem.Requests.Move as Move
import Game.Servers.Filesystem.Requests.Rename as Rename
import Game.Servers.Filesystem.Requests.Create as Create
import Game.Servers.Shared exposing (CId)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Network.Types exposing (NIP)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update :
    Game.Model
    -> CId
    -> Msg
    -> Model
    -> UpdateResponse
update game cid msg model =
    case msg of
        HandleDelete fileId ->
            handleDelete game cid fileId model

        HandleMove fileId newLocation ->
            handleMove game cid fileId newLocation model

        HandleRename fileId newBaseName ->
            handleRename game cid fileId newBaseName model

        HandleNewTextFile path name ->
            handleNewTextFile game cid path name model

        HandleNewDir path name ->
            handleNewDir game cid path name model

        Request request ->
            onRequest game cid (receive request) model



-- internals


handleDelete : Game.Model -> CId -> Id -> Model -> UpdateResponse
handleDelete game cid id model =
    let
        ( model_, cmd ) =
            case getFile id model of
                Just file ->
                    ( deleteFile id model
                    , Delete.request id cid game
                    )

                Nothing ->
                    ( model, Cmd.none )
    in
        ( model_, cmd, Dispatch.none )


handleMove :
    Game.Model
    -> CId
    -> Id
    -> Path
    -> Model
    -> UpdateResponse
handleMove game cid id newPath model =
    let
        ( model_, cmd ) =
            case getFile id model of
                Just file ->
                    ( moveFile id newPath model
                    , Move.request newPath id cid game
                    )

                Nothing ->
                    ( model, Cmd.none )
    in
        ( model_, cmd, Dispatch.none )


handleRename :
    Game.Model
    -> CId
    -> Id
    -> Name
    -> Model
    -> UpdateResponse
handleRename game cid id name model =
    let
        ( model_, cmd ) =
            case getFile id model of
                Just file ->
                    ( renameFile id name model
                    , Rename.request name id cid game
                    )

                Nothing ->
                    ( model, Cmd.none )
    in
        ( model_, cmd, Dispatch.none )


handleNewTextFile :
    Game.Model
    -> CId
    -> Path
    -> Name
    -> Model
    -> UpdateResponse
handleNewTextFile game cid path name model =
    let
        fullpath =
            appendPath name path

        file =
            File name "txt" path 0 Text

        model_ =
            insertFile (joinPath fullpath) file model
    in
        if model /= model_ then
            ( model_
            , Create.request "txt" name fullpath cid game
            , Dispatch.none
            )
        else
            Update.fromModel model


handleNewDir :
    Game.Model
    -> CId
    -> Path
    -> Name
    -> Model
    -> UpdateResponse
handleNewDir game cid path name model =
    let
        model_ =
            insertFolder path name model
    in
        if model /= model_ then
            ( model_
            , Create.request "/" name path cid game
            , Dispatch.none
            )
        else
            Update.fromModel model


onRequest :
    Game.Model
    -> CId
    -> Maybe Response
    -> Model
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
    -> Model
    -> UpdateResponse
updateRequest game cid data model =
    Update.fromModel model
