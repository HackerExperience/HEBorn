module Apps.DBAdmin.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.DBAdmin.Models exposing (..)
import Apps.DBAdmin.Messages as DBAdmin exposing (Msg(..))
import Apps.DBAdmin.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd DBAdmin.Msg, Dispatch )
actionHandler data action model =
    case action of
        NormalEntryEdit logId ->
            ( model, Cmd.none, Dispatch.none )

        EdittingEntryApply logId ->
            ( model, Cmd.none, Dispatch.none )

        EdittingEntryCancel logId ->
            ( model, Cmd.none, Dispatch.none )
