module Apps.Browser.Update exposing (update)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.Browser.Models
    exposing
        ( Model
        , gotoPage
        , gotoPreviousPage
        , gotoNextPage
        , enterAddress
        )
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Browser.Menu.Messages as MsgMenu
import Apps.Browser.Menu.Update
import Apps.Browser.Menu.Actions exposing (actionHandler)
import Apps.Browser.Menu.Actions exposing (actionHandler)


update : Msg -> GameModel -> Model -> ( Model, Cmd Msg, List CoreMsg )
update msg game ({ app } as model) =
    case msg of
        -- Menu
        MenuMsg (MsgMenu.MenuClick action) ->
            actionHandler action model game

        MenuMsg subMsg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Apps.Browser.Menu.Update.update subMsg model.menu game

                cmd_ =
                    Cmd.map MenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )

        UpdateAddress newAddr ->
            let
                app_ =
                    { app | addressBar = newAddr }
            in
                ( { model | app = app_ }, Cmd.none, [] )

        AddressEnter ->
            ( { model | app = enterAddress app }, Cmd.none, [] )

        GoPrevious ->
            let
                app_ =
                    gotoPreviousPage app
            in
                ( { model | app = app_ }, Cmd.none, [] )

        GoNext ->
            let
                app_ =
                    gotoNextPage app
            in
                ( { model | app = app_ }, Cmd.none, [] )
