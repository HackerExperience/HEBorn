module OS.Header.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Storyline as Storyline
import Core.Dispatch.Account as Account
import Core.Dispatch.Servers as Servers
import Game.Data as Game
import Game.Models
import Game.Account.Messages as Account
import Game.Meta.Types.Context exposing (Context)
import Game.Notifications.Messages as Notifications
import Game.Storyline.Messages as Story
import Game.Servers.Shared as Servers
import Game.Servers.Models as Servers
import OS.Header.Messages exposing (..)
import OS.Header.Models exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Data -> Msg -> Model -> UpdateResponse
update data msg model =
    case msg of
        Logout ->
            onLogout model

        ToggleMenus next ->
            onToggleMenus next model

        MouseEnterDropdown ->
            onMouseEnterDropdown model

        MouseLeavesDropdown ->
            onMouseLeavesDropdown model

        SelectGateway cid ->
            onSelectGateway cid model

        SelectBounce id ->
            onSelectBounce data id model

        SelectEndpoint cid ->
            onSelectEndpoint data cid model

        SelectNetwork nid ->
            -- TODO
            Update.fromModel model

        ContextTo context ->
            onContextTo context model

        CheckMenus ->
            onCheckMenus model

        ToggleCampaign ->
            onTogglecampaign model

        ServerReadAll cid ->
            onServerReadAll cid model

        ChatReadAll ->
            Update.fromModel model

        AccountReadAll ->
            onAccountReadAll model


onLogout : Model -> UpdateResponse
onLogout model =
    let
        dispatch =
            Dispatch.account Account.Logout
    in
        ( model, Cmd.none, dispatch )


onToggleMenus : OpenMenu -> Model -> UpdateResponse
onToggleMenus next ({ openMenu } as model) =
    let
        openMenu_ =
            if (openMenu /= NothingOpen && openMenu == next) then
                NothingOpen
            else
                next
    in
        Update.fromModel
            { model | openMenu = openMenu_ }


onMouseEnterDropdown : Model -> UpdateResponse
onMouseEnterDropdown model =
    Update.fromModel
        { model | mouseSomewhereInside = True }


onMouseLeavesDropdown : Model -> UpdateResponse
onMouseLeavesDropdown model =
    Update.fromModel
        { model | mouseSomewhereInside = False }


onSelectGateway : Maybe Servers.CId -> Model -> UpdateResponse
onSelectGateway cid model =
    let
        dispatch =
            case cid of
                Just cid ->
                    Dispatch.account <| Account.SetGateway cid

                Nothing ->
                    Dispatch.none

        model_ =
            { model | openMenu = NothingOpen }
    in
        ( model_, Cmd.none, dispatch )


onSelectBounce : Game.Data -> Maybe String -> Model -> UpdateResponse
onSelectBounce data id model =
    let
        dispatch =
            Dispatch.server
                (Game.getActiveCId data)
                (Servers.SetBounce id)

        model_ =
            { model | openMenu = NothingOpen }
    in
        ( model_, Cmd.none, dispatch )


onSelectEndpoint : Game.Data -> Maybe Servers.CId -> Model -> UpdateResponse
onSelectEndpoint data cid model =
    let
        dispatch =
            Dispatch.account <| Account.SetEndpoint cid

        model_ =
            { model | openMenu = NothingOpen }
    in
        ( model_, Cmd.none, dispatch )


onContextTo : Context -> Model -> UpdateResponse
onContextTo context model =
    let
        dispatch =
            Dispatch.account <| Account.SetContext context
    in
        ( model, Cmd.none, dispatch )


onCheckMenus : Model -> UpdateResponse
onCheckMenus ({ mouseSomewhereInside } as model) =
    let
        model_ =
            if not mouseSomewhereInside then
                { model | openMenu = NothingOpen }
            else
                model
    in
        Update.fromModel model_


onTogglecampaign : Model -> UpdateResponse
onTogglecampaign model =
    let
        dispatch =
            Dispatch.storyline <| Storyline.Toggle
    in
        ( model, Cmd.none, dispatch )


onServerReadAll : Servers.CId -> Model -> UpdateResponse
onServerReadAll cid model =
    let
        --Dispatch.server cid <|
        --Servers.NotificationsMsg
        --Notifications.ReadAll
        dispatch =
            Dispatch.none
    in
        ( model, Cmd.none, dispatch )


onAccountReadAll : Model -> UpdateResponse
onAccountReadAll model =
    let
        --Dispatch.account <|
        --    Account.NotificationsMsg
        --        Notifications.ReadAll
        dispatch =
            Dispatch.none
    in
        ( model, Cmd.none, dispatch )
