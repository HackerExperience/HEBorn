module Apps.LogViewer.Menu.Actions exposing (actionHandler)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.LogViewer.Models
    exposing
        ( Model
        , entryEnterEditing
        , entryApplyEditing
        , entryLeaveEditing
        , entryUpdateEditing
        )
import Apps.LogViewer.Messages exposing (Msg)
import Apps.LogViewer.Menu.Messages exposing (MenuAction(..))


actionHandler :
    MenuAction
    -> Model
    -> GameModel
    -> ( Model, Cmd Msg, List CoreMsg )
actionHandler action ({ app } as model) game =
    case action of
        NormalEntryEdit logID ->
            let
                entries_ =
                    entryEnterEditing logID app.entries

                model_ =
                    { model | app = { app | entries = entries_ } }
            in
                ( model_, Cmd.none, [] )

        EdittingEntryApply logID ->
            let
                entries_ =
                    entryApplyEditing logID app.entries

                model_ =
                    { model | app = { app | entries = entries_ } }
            in
                ( model_, Cmd.none, [] )

        EdittingEntryCancel logID ->
            let
                entries_ =
                    entryLeaveEditing logID app.entries

                model_ =
                    { model | app = { app | entries = entries_ } }
            in
                ( model_, Cmd.none, [] )
