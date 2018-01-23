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
import Game.Servers.Logs.Models as Logs
import Apps.LogViewer.Menu.Config exposing (..)
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Menu.Messages exposing (MenuAction(..))


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
            startCrypting config logId model

        DecryptEntry logId ->
            startDecrypting config logId model

        HideEntry logId ->
            startHiding config logId model

        DeleteEntry logId ->
            startDeleting config logId model


startCrypting : Config msg -> Logs.ID -> Model -> UpdateResponse msg
startCrypting { onEncryptLog } id model =
    id
        |> onEncryptLog
        |> React.msg
        |> (,) model


startDecrypting : Config msg -> Logs.ID -> Model -> UpdateResponse msg
startDecrypting config id model =
    ( model, React.none )


startHiding : Config msg -> Logs.ID -> Model -> UpdateResponse msg
startHiding { onHideLog } id model =
    id
        |> onHideLog
        |> React.msg
        |> (,) model


startDeleting : Config msg -> Logs.ID -> Model -> UpdateResponse msg
startDeleting { onDeleteLog } id model =
    id
        |> onDeleteLog
        |> React.msg
        |> (,) model


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
