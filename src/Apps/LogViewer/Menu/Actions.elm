module Apps.LogViewer.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Utils.Update as Update
import Game.Servers.Logs.Messages as Logs
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Messages as LogViewer exposing (Msg(..))
import Apps.LogViewer.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd LogViewer.Msg, Dispatch )
actionHandler data action ({ app } as model) =
    case action of
        NormalEntryEdit logId ->
            enterEditing data logId model
                |> Update.fromModel

        EdittingEntryApply logId ->
            let
                edited =
                    getEdit logId app

                dispatch =
                    case edited of
                        Just edited ->
                            Logs.UpdateContent edited
                                |> Dispatch.log (Game.getActiveCId data)
                                    logId

                        Nothing ->
                            Dispatch.none

                model_ =
                    { model | app = leaveEditing logId app }
            in
                ( model_, Cmd.none, dispatch )

        EdittingEntryCancel logId ->
            let
                app_ =
                    leaveEditing logId app

                model_ =
                    { model | app = app_ }
            in
                Update.fromModel model_

        EntryEncrypt logId ->
            let
                dispatch =
                    Logs.Encrypt
                        |> Dispatch.log
                            (Game.getActiveCId data)
                            logId
            in
                ( model, Cmd.none, dispatch )

        EntryDecrypt logId ->
            let
                dispatch =
                    Logs.Decrypt "NOT IMPLEMENTED YET"
                        |> Dispatch.log
                            (Game.getActiveCId data)
                            logId
            in
                ( model, Cmd.none, dispatch )

        EntryHide logId ->
            let
                dispatch =
                    Logs.Hide logId
                        |> Dispatch.logs
                            (Game.getActiveCId data)
            in
                ( model, Cmd.none, dispatch )

        EntryDelete logId ->
            let
                dispatch =
                    Logs.Delete logId
                        |> Dispatch.logs
                            (Game.getActiveCId data)
            in
                ( model, Cmd.none, dispatch )
