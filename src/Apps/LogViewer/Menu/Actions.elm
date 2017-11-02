module Apps.LogViewer.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Data as Game
import Utils.Update as Update
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Messages as LogViewer exposing (Msg(..))
import Apps.LogViewer.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd LogViewer.Msg, Dispatch )
actionHandler data action model =
    case action of
        NormalEntryEdit logId ->
            enterEditing data logId model
                |> Update.fromModel

        EdittingEntryApply logId ->
            let
                edited =
                    getEdit logId model

                dispatch =
                    case edited of
                        Just edited ->
                            edited
                                |> Servers.UpdateLog logId
                                |> Dispatch.logs (Game.getActiveCId data)

                        Nothing ->
                            Dispatch.none

                model_ =
                    leaveEditing logId model
            in
                ( model_, Cmd.none, dispatch )

        EdittingEntryCancel logId ->
            model
                |> leaveEditing logId
                |> Update.fromModel

        EncryptEntry logId ->
            let
                dispatch =
                    Logs.Encrypt
                        |> Dispatch.log
                            (Game.getActiveCId data)
                            logId
            in
                model
                ( model, Cmd.none, dispatch )

        DecryptEntry logId ->
            let
                dispatch =
                    Logs.Decrypt "NOT IMPLEMENTED YET"
                        |> Dispatch.log
                            (Game.getActiveCId data)
                            logId
            in
                ( model, Cmd.none, dispatch )

        HideEntry logId ->
            let
                dispatch =
                    Logs.Hide logId
                        |> Dispatch.logs
                            (Game.getActiveCId data)
            in
                ( model, Cmd.none, dispatch )

        DeleteEntry logId ->
            let
                dispatch =
                    Logs.Delete logId
                        |> Dispatch.logs
                            (Game.getActiveCId data)
            in
                ( model, Cmd.none, dispatch )
