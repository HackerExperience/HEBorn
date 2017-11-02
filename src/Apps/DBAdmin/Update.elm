module Apps.DBAdmin.Update exposing (update)

import Utils.Update as Update
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

        -- -- Real acts
        ToogleExpand tab itemId ->
            model
                |> toggleExpand itemId tab
                |> Update.fromModel

        EnterEditing tab itemId ->
            model
                |> enterEditing
                    itemId
                    tab
                    data.game.account.database
                |> Update.fromModel

        LeaveEditing tab itemId ->
            model
                |> leaveEditing itemId tab
                |> Update.fromModel

        UpdateTextFilter tab filter ->
            model
                |> updateTextFilter
                    filter
                    tab
                    data.game.account.database
                |> Update.fromModel

        EnterSelectingVirus serverIp ->
            model
                |> Servers.enterSelectingVirus
                    serverIp
                    data.game.account.database
                |> Update.fromModel

        UpdateServersSelectVirus serverIp virusId ->
            model
                |> Servers.updateSelectingVirus
                    virusId
                    serverIp
                |> Update.fromModel

        GoTab tab ->
            { model | selected = tab }
                |> Update.fromModel

        _ ->
            Update.fromModel model
