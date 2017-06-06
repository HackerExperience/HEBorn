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
            ( model, Cmd.none, [] )

        EdittingEntryApply logID ->
            ( model, Cmd.none, [] )

        EdittingEntryCancel logID ->
            ( model, Cmd.none, [] )
