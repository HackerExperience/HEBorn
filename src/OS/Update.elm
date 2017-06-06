module OS.Update exposing (update)

import OS.Messages exposing (..)
import OS.Models exposing (..)
import Game.Models exposing (GameModel)
import Core.Messages exposing (CoreMsg)
import OS.Menu.Messages as Menu
import OS.Menu.Update as Menu
import OS.Menu.Actions as MenuActions
import OS.SessionManager.Update as SessionManager
import OS.SessionManager.Messages as SessionManager
import OS.SessionManager.Models as SessionManager


update : OSMsg -> GameModel -> Model -> ( Model, Cmd OSMsg, List CoreMsg )
update msg game model =
    case msg of
        SessionManagerMsg msg ->
            model
                |> sessionManager msg game
                |> map (\m -> { model | session = m }) SessionManagerMsg

        ContextMenuMsg (Menu.MenuClick action) ->
            MenuActions.actionHandler action model game

        ContextMenuMsg subMsg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Menu.update subMsg model.menu game

                cmd_ =
                    Cmd.map ContextMenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )



-- Event _ ->
--     ( model, Cmd.none, [] )
-- Request _ ->
--     ( model, Cmd.none, [] )
-- Response _ _ ->
--     ( model, Cmd.none, [] )
-- internals


sessionManager :
    SessionManager.Msg
    -> GameModel
    -> Model
    -> ( SessionManager.Model, Cmd SessionManager.Msg, List CoreMsg )
sessionManager msg game model =
    SessionManager.update msg game model.session


map :
    (model -> Model)
    -> (msg -> OSMsg)
    -> ( model, Cmd msg, List CoreMsg )
    -> ( Model, Cmd OSMsg, List CoreMsg )
map mapModel mapMsg ( model, msg, cmds ) =
    ( mapModel model, Cmd.map mapMsg msg, cmds )
