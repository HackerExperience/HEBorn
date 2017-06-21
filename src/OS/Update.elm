module OS.Update exposing (update)

import OS.Messages exposing (..)
import OS.Models exposing (..)
import Game.Models as Game
import Core.Messages as Core
import OS.Menu.Messages as Menu
import OS.Menu.Update as Menu
import OS.Menu.Actions as MenuActions
import OS.SessionManager.Update as SessionManager
import OS.SessionManager.Messages as SessionManager
import OS.SessionManager.Models as SessionManager


update : Msg -> Game.Model -> Model -> ( Model, Cmd Msg, List Core.Msg )
update msg game model =
    case msg of
        SessionManagerMsg msg ->
            model
                |> sessionManager msg game
                |> map (\m -> { model | session = m }) SessionManagerMsg

        MenuMsg (Menu.MenuClick action) ->
            MenuActions.actionHandler action model game

        MenuMsg subMsg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Menu.update subMsg model.menu game

                cmd_ =
                    Cmd.map MenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )



-- internals


sessionManager :
    SessionManager.Msg
    -> Game.Model
    -> Model
    -> ( SessionManager.Model, Cmd SessionManager.Msg, List Core.Msg )
sessionManager msg game model =
    SessionManager.update msg game model.session


map :
    (model -> Model)
    -> (msg -> Msg)
    -> ( model, Cmd msg, List Core.Msg )
    -> ( Model, Cmd Msg, List Core.Msg )
map mapModel mapMsg ( model, msg, cmds ) =
    ( mapModel model, Cmd.map mapMsg msg, cmds )
