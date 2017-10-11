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
import OS.SessionManager.WindowManager.Messages as WindowManager
import OS.Toasts.Messages as Toasts
import OS.Toasts.Update as Toasts
import Apps.Messages as Apps


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Data -> Msg -> Model -> UpdateResponse
update data msg model =
    case msg of
        SessionManagerMsg msg ->
            onSessionManagerMsg data msg model

        HeaderMsg msg ->
            onHeaderMsg data msg model

        ToastsMsg msg ->
            onToastsMsg data msg model

        Event event ->
            onEvent data event model

        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model



-- internals


onSessionManagerMsg :
    Game.Data
    -> SessionManager.Msg
    -> Model
    -> UpdateResponse
onSessionManagerMsg data msg model =
    Update.child
        { get = .session
        , set = (\session model -> { model | session = session })
        , toMsg = SessionManagerMsg
        , update = (SessionManager.update data)
        }
        msg
        model


onHeaderMsg :
    Game.Data
    -> Header.Msg
    -> Model
    -> UpdateResponse
onHeaderMsg data msg model =
    Update.child
        { get = .header
        , set = (\header model -> { model | header = header })
        , toMsg = HeaderMsg
        , update = (Header.update data)
        }
        msg
        model


onToastsMsg : Game.Data -> Toasts.Msg -> Model -> UpdateResponse
onToastsMsg data msg model =
    Update.child
        { get = .toasts
        , set = (\toasts model -> { model | toasts = toasts })
        , toMsg = ToastsMsg
        , update = (Toasts.update data)
        }
        msg
        model


onMenuMsg : Game.Data -> Menu.Msg -> Model -> UpdateResponse
onMenuMsg data msg model =
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


onEvent : Game.Data -> Events.Event -> Model -> UpdateResponse
onEvent data event model =
    model
        |> onToastsMsg data (Toasts.Event event)
        |> Update.andThen
            (event
                |> Apps.Event
                |> WindowManager.EveryAppMsg
                |> SessionManager.WindowManagerMsg
                |> onSessionManagerMsg data
            )
