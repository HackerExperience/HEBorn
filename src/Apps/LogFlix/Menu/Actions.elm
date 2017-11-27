module Apps.LogFlix.Menu.Actions
    exposing
        ( actionHandler
        , startCrypting
        , startDecrypting
        , startHiding
        , startDeleting
        )

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Data as Game
import Utils.Update as Update
import Game.Servers.Logs.Models as Logs
import Apps.LogFlix.Models exposing (..)
import Apps.LogFlix.Messages as LogFlix exposing (Msg(..))
import Apps.LogFlix.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd LogFlix.Msg, Dispatch )
actionHandler data action model =
    case action of
        NormalEntryEdit logId ->
            enterEditing data logId model
                |> Update.fromModel

        EdittingEntryApply logId ->
            model
                |> enterEditing data logId
                |> Update.fromModel

        EdittingEntryCancel logId ->
            model
                |> leaveEditing logId
                |> Update.fromModel

        EncryptEntry logId ->
            let
                dispatch =
                    startCrypting logId data model
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
                    startHiding logId data model
            in
                ( model, Cmd.none, dispatch )

        DeleteEntry logId ->
            let
                dispatch =
                    startDeleting logId data model
            in
                ( model, Cmd.none, dispatch )


startCrypting : Logs.ID -> Game.Data -> Model -> Dispatch
startCrypting id data model =
    let
        dispatch =
            id
                |> Servers.EncryptLog
                |> Dispatch.logs (Game.getActiveCId data)
    in
        dispatch


startDecrypting : Logs.ID -> Model -> Dispatch
startDecrypting id model =
    Dispatch.none


startHiding : Logs.ID -> Game.Data -> Model -> Dispatch
startHiding id data model =
    let
        dispatch =
            id
                |> Servers.HideLog
                |> Dispatch.logs (Game.getActiveCId data)
    in
        dispatch


startDeleting : Logs.ID -> Game.Data -> Model -> Dispatch
startDeleting id data model =
    let
        dispatch =
            id
                |> Servers.DeleteLog
                |> Dispatch.logs (Game.getActiveCId data)
    in
        dispatch
