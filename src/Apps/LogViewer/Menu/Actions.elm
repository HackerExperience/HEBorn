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
import Utils.React as React exposing (React)
import Game.Data as Game
import Game.Servers.Logs.Models as Logs
import Apps.LogViewer.Menu.Config exposing (..)
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Messages as LogViewer exposing (Msg(..))
import Apps.LogViewer.Menu.Messages exposing (MenuAction(..))


--CONFREFACT : Fix these dispatches


type alias UpdateResponse msg =
    ( Model, React msg )


actionHandler :
    Config msg
    -> MenuAction
    -> Model
    -> UpdateResponse msg
actionHandler config action model =
    case action of
        NormalEntryEdit logId ->
            ( enterEditing config logId model, React.none )

        EdittingEntryApply logId ->
            ( enterEditing config logId model, React.none )

        EdittingEntryCancel logId ->
            ( leaveEditing logId model, React.none )

        EncryptEntry logId ->
            --let
            --    dispatch =
            --        startCrypting logId config model
            --in
            startCrypting logId config model

        DecryptEntry logId ->
            --let
            --    dispatch =
            --        startDecrypting logId model
            --in
            startDecrypting logId model

        HideEntry logId ->
            --let
            --    dispatch =
            --        startHiding logId config model
            --in
            startHiding logId config model

        DeleteEntry logId ->
            --let
            --    dispatch =
            --        startDeleting logId config model
            --in
            startDeleting logId config model


startCrypting : Logs.ID -> Config msg -> Model -> UpdateResponse msg
startCrypting id config model =
    --let
    --    dispatch =
    --        id
    --            |> Servers.EncryptLog
    --            |> Dispatch.logs config.activeCId
    --in
    --    dispatch
    ( model, React.none )


startDecrypting : Logs.ID -> Model -> UpdateResponse msg
startDecrypting id model =
    ( model, React.none )


startHiding : Logs.ID -> Config msg -> Model -> UpdateResponse msg
startHiding id config model =
    --let
    --    dispatch =
    --        id
    --            |> Servers.HideLog
    --            |> Dispatch.logs config.activeCId
    --in
    --    dispatch
    ( model, React.none )


startDeleting : Logs.ID -> Config msg -> Model -> UpdateResponse msg
startDeleting id config model =
    --let
    --    dispatch =
    --        id
    --            |> Servers.DeleteLog
    --            |> Dispatch.logs config.activeCId
    --in
    --    dispatch
    ( model, React.none )


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
