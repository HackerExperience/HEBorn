module Apps.Bug.Update exposing (update)

import Core.Error as Error
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Account as Account
import Game.Data as Game
import Native.Panic
import OS.Toasts.Messages as Toasts
import OS.Toasts.Models as Toasts
import Apps.Bug.Models exposing (Model)
import Apps.Bug.Messages as Hackerbug exposing (Msg(..))
import Apps.Bug.Menu.Messages as Menu
import Apps.Bug.Menu.Update as Menu
import Apps.Bug.Menu.Actions as Menu


update :
    Game.Data
    -> Hackerbug.Msg
    -> Model
    -> ( Model, Cmd Hackerbug.Msg, Dispatch )
update data msg model =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Menu.update data msg model.menu

                cmd_ =
                    Cmd.map MenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )

        DummyToast ->
            ( model
            , Cmd.none
            , Dispatch.toasts <|
                Toasts.Append Toasts.dummy
            )

        PoliteCrash ->
            ( model
            , Cmd.none
            , Dispatch.account <|
                Account.LogoutAndCrash <|
                    Error.fakeTest "This is a polite crash."
            )

        UnpoliteCrash ->
            Native.Panic.crash <|
                Error.fakeTest "This is an unpolite crash."
