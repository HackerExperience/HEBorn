module Game.Servers.Filesystem.Update exposing (update)

import Utils.Update as Update
import Game.Servers.Filesystem.Config exposing (..)
import Game.Servers.Filesystem.Messages exposing (..)
import Game.Servers.Filesystem.Models exposing (..)
import Game.Servers.Filesystem.Requests exposing (..)
import Game.Servers.Filesystem.Requests.Delete as Delete
import Game.Servers.Filesystem.Requests.Move as Move
import Game.Servers.Filesystem.Requests.Rename as Rename
import Game.Servers.Filesystem.Requests.Create as Create
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        HandleDelete fileId ->
            handleDelete config fileId model

        HandleMove fileId newLocation ->
            handleMove config fileId newLocation model

        HandleRename fileId newBaseName ->
            handleRename config fileId newBaseName model

        HandleNewTextFile path name ->
            handleNewTextFile config path name model

        HandleNewDir path name ->
            handleNewDir config path name model

        HandleAdded id file ->
            onHandleAdded id file model

        Request request ->
            onRequest config (receive request) model



-- internals


handleDelete : Config msg -> Id -> Model -> UpdateResponse msg
handleDelete config id model =
    let
        ( model_, cmd ) =
            case getFile id model of
                Just file ->
                    ( deleteFile id model
                    , Delete.request id config.cid config
                        |> Cmd.map config.toMsg
                    )

                Nothing ->
                    ( model, Cmd.none )
    in
        ( model_, cmd, Dispatch.none )


handleMove :
    Config msg
    -> Id
    -> Path
    -> Model
    -> UpdateResponse msg
handleMove config id newPath model =
    let
        ( model_, cmd ) =
            case getFile id model of
                Just file ->
                    ( moveFile id newPath model
                    , Move.request newPath id config.cid config
                        |> Cmd.map config.toMsg
                    )

                Nothing ->
                    ( model, Cmd.none )
    in
        ( model_, cmd, Dispatch.none )


handleRename :
    Config msg
    -> Id
    -> Name
    -> Model
    -> UpdateResponse msg
handleRename config id name model =
    let
        ( model_, cmd ) =
            case getFile id model of
                Just file ->
                    ( renameFile id name model
                    , Rename.request name id config.cid config
                        |> Cmd.map config.toMsg
                    )

                Nothing ->
                    ( model, Cmd.none )
    in
        ( model_, cmd, Dispatch.none )


handleNewTextFile :
    Config msg
    -> Path
    -> Name
    -> Model
    -> UpdateResponse msg
handleNewTextFile config path name model =
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
            , Create.request "txt" name fullpath config.cid config
                |> Cmd.map config.toMsg
            , Dispatch.none
            )
        else
            Update.fromModel model


handleNewDir :
    Config msg
    -> Path
    -> Name
    -> Model
    -> UpdateResponse msg
handleNewDir config path name model =
    let
        model_ =
            insertFolder path name model
    in
        if model /= model_ then
            ( model_
            , Create.request "/" name path config.cid config
                |> Cmd.map config.toMsg
            , Dispatch.none
            )
        else
            Update.fromModel model


onHandleAdded : Id -> File -> Model -> UpdateResponse msg
onHandleAdded id file model =
    ( insertFile id file model
    , Cmd.none
    , Dispatch.none
    )


onRequest :
    Config msg
    -> Maybe Response
    -> Model
    -> UpdateResponse msg
onRequest config response model =
    case response of
        Just response ->
            updateRequest config response model

        Nothing ->
            Update.fromModel model


updateRequest :
    Config msg
    -> Response
    -> Model
    -> UpdateResponse msg
updateRequest config data model =
    Update.fromModel model
