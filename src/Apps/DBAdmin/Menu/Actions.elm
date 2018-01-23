module Apps.DBAdmin.Menu.Actions exposing (actionHandler)

import Utils.React as React exposing (React)
import Apps.DBAdmin.Menu.Config exposing (..)
import Apps.DBAdmin.Models exposing (..)
import Apps.DBAdmin.Messages as DBAdmin exposing (Msg(..))
import Apps.DBAdmin.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Config msg
    -> MenuAction
    -> Model
    -> ( Model, React msg )
actionHandler config action model =
    case action of
        NormalEntryEdit logId ->
            ( model, React.none )

        EdittingEntryApply logId ->
            ( model, React.none )

        EdittingEntryCancel logId ->
            ( model, React.none )
