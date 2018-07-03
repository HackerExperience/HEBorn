module Game.Servers.Filesystem.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Servers.Filesystem.Requests.Delete exposing (deleteRequest)
import Game.Servers.Filesystem.Requests.Move exposing (moveRequest)
import Game.Servers.Filesystem.Requests.Rename exposing (renameRequest)
import Game.Servers.Filesystem.Requests.Create exposing (createRequest)
import Game.Servers.Filesystem.Config exposing (..)
import Game.Servers.Filesystem.Messages exposing (..)
import Game.Servers.Filesystem.Models exposing (..)
import Game.Servers.Filesystem.Shared exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


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



-- funções internas


{-| Deleta um arquivo quando recebe a mensagem `HandleDelete`.
-}
handleDelete : Config msg -> Id -> Model -> UpdateResponse msg
handleDelete config id model =
    case getFile id model of
        Just file ->
            ( deleteFile id model
            , config
                |> deleteRequest id config.cid
                |> Cmd.map (always <| config.batchMsg [])
                |> React.cmd
            )

        Nothing ->
            ( model, React.none )


{-| Move um arquivo quando recebe a mensagem `HandleMove`.
-}
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
                    , config
                        |> moveRequest newPath id config.cid
                        |> Cmd.map (always <| config.batchMsg [])
                        |> React.cmd
                    )

                Nothing ->
                    ( model, React.none )
    in
        ( model_, cmd )


{-| Renomeia um arquivo quando recebe a mensagem `HandleRename`.
-}
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
                    , config
                        |> renameRequest name id config.cid
                        |> Cmd.map (always <| config.batchMsg [])
                        |> React.cmd
                    )

                Nothing ->
                    ( model, React.none )
    in
        ( model_, cmd )


{-| Cria um arquivo de texto novo quando recebe a mensagem `HandleNewTextFile`.
-}
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
            , config
                |> createRequest "txt" name fullpath config.cid
                |> Cmd.map (always <| config.batchMsg [])
                |> React.cmd
            )
        else
            ( model, React.none )


{-| Cria um diretório novo quando recebe a mensagem `HandleNewDir`.
-}
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
            , config
                |> createRequest "/" name path config.cid
                |> Cmd.map (always <| config.batchMsg [])
                |> React.cmd
            )
        else
            ( model, React.none )


{-| Cria um arquivo de texto novo quando recebe a mensagem `HandleAdded`, que
é criada por um evento.
-}
onHandleAdded : Id -> File -> Model -> UpdateResponse msg
onHandleAdded id file model =
    ( insertFile id file model, React.none )
