module OS.Update exposing (update)

import Utils.Update as Update
import Events.Events as Events
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import OS.Header.Messages as Header
import OS.Header.Models as Header
import OS.Header.Update as Header
import OS.Messages exposing (..)
import OS.Models exposing (..)
import OS.Menu.Messages as Menu
import OS.Menu.Update as Menu
import OS.Menu.Actions as Menu
import OS.SessionManager.Messages as SessionManager
import OS.SessionManager.Models as SessionManager
import OS.SessionManager.Update as SessionManager
import OS.Toasts.Messages as Toasts
import OS.Toasts.Update as Toasts


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Data -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        SessionManagerMsg msg ->
            model
                |> sessionManager game msg
                |> map (\m -> { model | session = m }) SessionManagerMsg

        HeaderMsg msg ->
            model
                |> header game msg
                |> map (\m -> { model | header = m }) HeaderMsg

        ToastsMsg msg ->
            onToastsMsg game msg model

        Event data ->
            onEvent game data model

        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler game action model

        MenuMsg msg ->
            let
                ( menu_, menu_cmd, dispatch_ ) =
                    Menu.update game msg model.menu

                ( header_, _, _ ) =
                    header game Header.CheckMenus model

                cmd_ =
                    Cmd.map MenuMsg menu_cmd

                model_ =
                    { model | menu = menu_, header = header_ }
            in
                ( model_, cmd_, dispatch_ )



-- internals


sessionManager :
    Game.Data
    -> SessionManager.Msg
    -> Model
    -> ( SessionManager.Model, Cmd SessionManager.Msg, Dispatch )
sessionManager data msg model =
    SessionManager.update data msg model.session


header :
    Game.Data
    -> Header.Msg
    -> Model
    -> ( Header.Model, Cmd Header.Msg, Dispatch )
header game msg model =
    Header.update game msg model.header


map :
    (model -> Model)
    -> (msg -> Msg)
    -> ( model, Cmd msg, Dispatch )
    -> ( Model, Cmd Msg, Dispatch )
map mapModel mapMsg ( model, msg, cmds ) =
    ( mapModel model, Cmd.map mapMsg msg, cmds )


onToastsMsg : Game.Data -> Toasts.Msg -> Model -> UpdateResponse
onToastsMsg game msg model =
    Update.child
        { get = .toasts
        , set = (\toasts model -> { model | toasts = toasts })
        , toMsg = ToastsMsg
        , update = (Toasts.update game)
        }
        msg
        model


onEvent : Game.Data -> Events.Event -> Model -> UpdateResponse
onEvent game event model =
    onToastsMsg game (Toasts.Event event) model
