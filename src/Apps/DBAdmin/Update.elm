module Apps.DBAdmin.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.DBAdmin.Models exposing (..)
import Apps.DBAdmin.Tabs exposing (..)
import Apps.DBAdmin.Messages as DBAdmin exposing (Msg(..))
import Apps.DBAdmin.Menu.Messages as Menu
import Apps.DBAdmin.Menu.Update as Menu
import Apps.DBAdmin.Menu.Actions as Menu
import Apps.DBAdmin.Tabs.Servers.Helpers as Servers


update :
    Game.Data
    -> DBAdmin.Msg
    -> Model
    -> ( Model, Cmd DBAdmin.Msg, Dispatch )
update data msg ({ app } as model) =
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

        -- -- Real acts
        ToogleExpand tab itemId ->
            let
                app_ =
                    toggleExpand itemId tab app
            in
                ( { model | app = app_ }, Cmd.none, Dispatch.none )

        EnterEditing tab itemId ->
            let
                app_ =
                    enterEditing
                        itemId
                        tab
                        data.game.account.database
                        app
            in
                ( { model | app = app_ }, Cmd.none, Dispatch.none )

        LeaveEditing tab itemId ->
            let
                app_ =
                    leaveEditing itemId tab app
            in
                ( { model | app = app_ }, Cmd.none, Dispatch.none )

        UpdateTextFilter tab filter ->
            let
                app_ =
                    updateTextFilter
                        filter
                        tab
                        data.game.account.database
                        app
            in
                ( { model | app = app_ }, Cmd.none, Dispatch.none )

        EnterSelectingVirus serverIp ->
            let
                app_ =
                    Servers.enterSelectingVirus
                        serverIp
                        data.game.account.database
                        app
            in
                ( { model | app = app_ }, Cmd.none, Dispatch.none )

        UpdateServersSelectVirus serverIp virusId ->
            let
                app_ =
                    Servers.updateSelectingVirus
                        virusId
                        serverIp
                        app
            in
                ( { model | app = app_ }, Cmd.none, Dispatch.none )

        GoTab tab ->
            let
                model_ =
                    { model | app = { app | selected = tab } }
            in
                ( model_, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )
