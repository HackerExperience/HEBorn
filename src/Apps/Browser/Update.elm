module Apps.Browser.Update exposing (update)

import Game.Models as Game
import Apps.Browser.Models
    exposing
        ( Model
        , gotoPage
        , gotoPreviousPage
        , gotoNextPage
        , enterAddress
        )
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Browser.Menu.Messages as Menu
import Apps.Browser.Menu.Update as Menu
import Apps.Browser.Menu.Actions as Menu
import Core.Dispatch as Dispatch exposing (Dispatch)


update : Game.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update game msg ({ app } as model) =
    case msg of
        -- Menu
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler game action model

        MenuMsg msg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Menu.update game msg model.menu

                cmd_ =
                    Cmd.map MenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )

        UpdateAddress newAddr ->
            let
                app_ =
                    { app | addressBar = newAddr }
            in
                ( { model | app = app_ }, Cmd.none, Dispatch.none )

        AddressEnter ->
            ( { model | app = enterAddress app }, Cmd.none, Dispatch.none )

        GoPrevious ->
            let
                app_ =
                    gotoPreviousPage app
            in
                ( { model | app = app_ }, Cmd.none, Dispatch.none )

        GoNext ->
            let
                app_ =
                    gotoNextPage app
            in
                ( { model | app = app_ }, Cmd.none, Dispatch.none )
