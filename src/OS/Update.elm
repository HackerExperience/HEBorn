module OS.Update exposing (update)

import OS.Header.Messages as Header
import OS.Header.Models as Header
import OS.Header.Update as Header
import OS.Messages exposing (..)
import OS.Models exposing (..)
import Game.Models as Game
import OS.Menu.Messages as Menu
import OS.Menu.Update as Menu
import OS.Menu.Actions as MenuActions
import OS.SessionManager.Update as SessionManager
import OS.SessionManager.Messages as SessionManager
import OS.SessionManager.Models as SessionManager
import Core.Dispatch as Dispatch exposing (Dispatch)


update : Msg -> Game.Model -> Model -> ( Model, Cmd Msg, Dispatch )
update msg game model =
    case msg of
        SessionManagerMsg msg ->
            model
                |> sessionManager msg game
                |> map (\m -> { model | session = m }) SessionManagerMsg

        HeaderMsg msg ->
            model
                |> header msg game
                |> map (\m -> { model | header = m }) HeaderMsg

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
    -> ( SessionManager.Model, Cmd SessionManager.Msg, Dispatch )
sessionManager msg game model =
    SessionManager.update msg game model.session


header :
    Header.Msg
    -> Game.Model
    -> Model
    -> ( Header.Model, Cmd Header.Msg, Dispatch )
header msg game model =
    Header.update msg game model.header


map :
    (model -> Model)
    -> (msg -> Msg)
    -> ( model, Cmd msg, Dispatch )
    -> ( Model, Cmd Msg, Dispatch )
map mapModel mapMsg ( model, msg, cmds ) =
    ( mapModel model, Cmd.map mapMsg msg, cmds )
