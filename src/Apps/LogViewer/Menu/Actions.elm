module Apps.LogViewer.Menu.Actions
    exposing
        ( actionHandler
        , startCrypting
        , startDecrypting
        , startHiding
        , startDeleting
        , enterEditing
        )

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Data as Game
import Utils.Update as Update
import Game.Servers.Logs.Models as Logs
import Apps.LogViewer.Menu.Config exposing (..)
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Messages as LogViewer exposing (Msg(..))
import Apps.LogViewer.Menu.Messages exposing (MenuAction(..))


--CONFREFACT : Fix these dispatches


actionHandler :
    Config msg
    -> MenuAction
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
actionHandler config action model =
    case action of
        NormalEntryEdit logId ->
            enterEditing config logId model
                |> Update.fromModel

        EdittingEntryApply logId ->
            model
                |> enterEditing config logId
                |> Update.fromModel

        EdittingEntryCancel logId ->
            model
                |> leaveEditing logId
                |> Update.fromModel

        EncryptEntry logId ->
            let
                dispatch =
                    startCrypting logId config model
            in
                ( model, Cmd.none, dispatch )

        DecryptEntry logId ->
            let
                dispatch =
                    startDecrypting logId model
            in
                ( model, Cmd.none, dispatch )

        HideEntry logId ->
            let
                dispatch =
                    startHiding logId config model
            in
                ( model, Cmd.none, dispatch )

        DeleteEntry logId ->
            let
                dispatch =
                    startDeleting logId config model
            in
                ( model, Cmd.none, dispatch )


startCrypting : Logs.ID -> Config msg -> Model -> Dispatch
startCrypting id config model =
    --let
    --    dispatch =
    --        id
    --            |> Servers.EncryptLog
    --            |> Dispatch.logs config.activeCId
    --in
    --    dispatch
    Dispatch.none


startDecrypting : Logs.ID -> Model -> Dispatch
startDecrypting id model =
    Dispatch.none


startHiding : Logs.ID -> Config msg -> Model -> Dispatch
startHiding id config model =
    --let
    --    dispatch =
    --        id
    --            |> Servers.HideLog
    --            |> Dispatch.logs config.activeCId
    --in
    --    dispatch
    Dispatch.none


startDeleting : Logs.ID -> Config msg -> Model -> Dispatch
startDeleting id config model =
    --let
    --    dispatch =
    --        id
    --            |> Servers.DeleteLog
    --            |> Dispatch.logs config.activeCId
    --in
    --    dispatch
    Dispatch.none


enterEditing : Config msg -> Logs.ID -> Model -> Model
enterEditing config id model =
    let
        logs =
            config.logs

        model_ =
            case Dict.get id logs.logs of
                Just log ->
                    case Logs.getContent log of
                        Logs.NormalContent data ->
                            Just <| updateEditing id data.raw model

                        Logs.Encrypted ->
                            Nothing

                _ ->
                    Nothing
    in
        Maybe.withDefault model model_
