module Apps.DBAdmin.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Models as Game
import Game.Account.Models as Account
import Game.Servers.Logs.Models exposing (ID)
import Apps.DBAdmin.Models exposing (..)
import Apps.DBAdmin.Tabs exposing (..)
import Apps.DBAdmin.Messages as DBAdmin exposing (Msg(..))
import Apps.DBAdmin.Menu.Messages as Menu
import Apps.DBAdmin.Menu.Update as Menu
import Apps.DBAdmin.Menu.Actions as Menu
import Apps.DBAdmin.Tabs.Servers.Helpers as Servers


type alias UpdateResponse =
    ( Model, Cmd DBAdmin.Msg, Dispatch )


update :
    Game.Data
    -> DBAdmin.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model

        -- -- Real acts
        ToogleExpand tab itemId ->
            onToogleExpand tab itemId model

        EnterEditing tab itemId ->
            onEnterEditing data tab itemId model

        LeaveEditing tab itemId ->
            onLeaveEditing tab itemId model

        UpdateTextFilter tab filter ->
            onUpdateTextFilter data tab filter model

        EnterSelectingVirus serverIp ->
            onEnterSelectingVirus data serverIp model

        UpdateServersSelectVirus serverIp virusId ->
            onUpdateServersSelectVirus serverIp virusId model

        GoTab tab ->
            onGoTab tab model

        _ ->
            Update.fromModel model


onMenuMsg : Game.Data -> Menu.Msg -> Model -> UpdateResponse
onMenuMsg data msg model =
    let
        ( menu_, cmd, coreMsg ) =
            Menu.update data msg model.menu

        cmd_ =
            Cmd.map MenuMsg cmd

        model_ =
            { model | menu = menu_ }
    in
        ( model_, cmd_, coreMsg )


onToogleExpand : MainTab -> ID -> Model -> UpdateResponse
onToogleExpand tab itemId model =
    model
        |> toggleExpand itemId tab
        |> Update.fromModel


onEnterEditing : Game.Data -> MainTab -> ID -> Model -> UpdateResponse
onEnterEditing data tab itemId model =
    let
        database =
            data
                |> Game.getGame
                |> Game.getAccount
                |> Account.getDatabase
    in
        model
            |> enterEditing
                itemId
                tab
                database
            |> Update.fromModel


onLeaveEditing : MainTab -> ID -> Model -> UpdateResponse
onLeaveEditing tab itemId model =
    model
        |> leaveEditing itemId tab
        |> Update.fromModel


onUpdateTextFilter : Game.Data -> MainTab -> String -> Model -> UpdateResponse
onUpdateTextFilter data tab filter model =
    let
        database =
            data
                |> Game.getGame
                |> Game.getAccount
                |> Account.getDatabase
    in
        model
            |> updateTextFilter
                filter
                tab
                database
            |> Update.fromModel


onEnterSelectingVirus : Game.Data -> ID -> Model -> UpdateResponse
onEnterSelectingVirus data serverIp model =
    let
        database =
            data
                |> Game.getGame
                |> Game.getAccount
                |> Account.getDatabase
    in
        model
            |> Servers.enterSelectingVirus
                serverIp
                database
            |> Update.fromModel


onUpdateServersSelectVirus : ID -> ID -> Model -> UpdateResponse
onUpdateServersSelectVirus serverIp virusId model =
    model
        |> Servers.updateSelectingVirus
            virusId
            serverIp
        |> Update.fromModel


onGoTab : MainTab -> Model -> UpdateResponse
onGoTab tab model =
    { model | selected = tab }
        |> Update.fromModel
