module OS.Header.Update exposing (update)

--TODO: Convert this entirely to Utils.Update

import Utils.Update as Update
import UI.Widgets.CustomSelect as CustomSelect
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Account.Messages as Account
import Game.Data as Game
import Game.Meta.Messages as Meta
import Game.Account.Messages as Account
import Game.Storyline.Messages as Story
import Game.Servers.Messages as Servers
import OS.Header.Messages exposing (..)
import OS.Header.Models exposing (..)


update : Game.Data -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update data msg ({ openMenu } as model) =
    case msg of
        Logout ->
            let
                dispatch =
                    Dispatch.account Account.DoLogout
            in
                ( model, Cmd.none, dispatch )

        ToggleMenus next ->
            let
                openMenu_ =
                    if (openMenu /= NothingOpen && openMenu == next) then
                        NothingOpen
                    else
                        next

                model_ =
                    { model | openMenu = openMenu_ }
            in
                Update.fromModel model_

        CustomSelect CustomSelect.MouseEnter ->
            let
                model_ =
                    { model | mouseSomewhereInside = True }
            in
                Update.fromModel model_

        CustomSelect CustomSelect.MouseLeave ->
            let
                model_ =
                    { model | mouseSomewhereInside = False }
            in
                Update.fromModel model_

        SelectGateway id ->
            let
                dispatch =
                    case id of
                        Just id ->
                            Dispatch.account <| Account.SetGateway id

                        Nothing ->
                            Dispatch.none

                model_ =
                    { model | openMenu = NothingOpen }
            in
                ( model_, Cmd.none, dispatch )

        SelectBounce id ->
            let
                dispatch =
                    Dispatch.server data.id <| Servers.SetBounce id

                model_ =
                    { model | openMenu = NothingOpen }
            in
                ( model_, Cmd.none, dispatch )

        SelectEndpoint serverId ->
            let
                dispatch =
                    Dispatch.account <| Account.SetEndpoint serverId

                model_ =
                    { model | openMenu = NothingOpen }
            in
                ( model_, Cmd.none, dispatch )

        ContextTo context ->
            let
                dispatch =
                    Dispatch.account <| Account.ContextTo context
            in
                ( model, Cmd.none, dispatch )

        CheckMenus ->
            let
                model_ =
                    if not model.mouseSomewhereInside then
                        { model | openMenu = NothingOpen }
                    else
                        model
            in
                Update.fromModel model_

        NotificationsTabGo target ->
            let
                model_ =
                    { model | activeNotificationsTab = target }
            in
                Update.fromModel model_

        ToggleCampaign ->
            let
                dispatch =
                    Dispatch.story <| Story.Toggle
            in
                ( model, Cmd.none, dispatch )
