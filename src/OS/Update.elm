module OS.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import OS.Header.Messages as Header
import OS.Header.Update as Header
import OS.Config exposing (..)
import OS.Messages exposing (..)
import OS.Models exposing (..)
import OS.Menu.Messages as Menu
import OS.Menu.Update as Menu
import OS.Menu.Actions as Menu
import OS.SessionManager.Messages as SessionManager
import OS.SessionManager.Update as SessionManager
import OS.Toasts.Messages as Toasts
import OS.Toasts.Update as Toasts


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Game.Data -> Msg -> Model -> UpdateResponse msg
update config data msg model =
    case msg of
        SessionManagerMsg msg ->
            onSessionManagerMsg config data msg model

        HeaderMsg msg ->
            onHeaderMsg config data msg model

        ToastsMsg msg ->
            onToastsMsg config data msg model

        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler config data action model

        MenuMsg msg ->
            onMenuMsg data msg model



-- internals


onSessionManagerMsg :
    Config msg
    -> Game.Data
    -> SessionManager.Msg
    -> Model
    -> UpdateResponse msg
onSessionManagerMsg config data msg model =
    Update.child
        { get = .session
        , set = (\session model -> { model | session = session })
        , toMsg = SessionManagerMsg
        , update = (SessionManager.update data)
        }
        msg
        model


onHeaderMsg :
    Config msg
    -> Game.Data
    -> Header.Msg
    -> Model
    -> UpdateResponse msg
onHeaderMsg config data msg model =
    Update.child
        { get = .header
        , set = (\header model -> { model | header = header })
        , toMsg = HeaderMsg
        , update = (Header.update data)
        }
        msg
        model


onToastsMsg : Config msg -> Game.Data -> Toasts.Msg -> Model -> UpdateResponse msg
onToastsMsg config data msg model =
    Update.child
        { get = .toasts
        , set = (\toasts model -> { model | toasts = toasts })
        , toMsg = ToastsMsg
        , update = (Toasts.update data)
        }
        msg
        model


onMenuMsg : Config msg -> Game.Data -> Menu.Msg -> Model -> UpdateResponse msg
onMenuMsg config data msg model =
    let
        ( menu_, menu_cmd, dispatch_ ) =
            Menu.update data msg model.menu

        ( modelHeader, _, _ ) =
            onHeaderMsg data Header.CheckMenus model

        cmd_ =
            Cmd.map MenuMsg menu_cmd

        model_ =
            { modelHeader | menu = menu_ }
    in
        ( model_, cmd_, dispatch_ )
