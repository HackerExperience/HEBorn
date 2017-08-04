module OS.Header.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import UI.Widgets.CustomSelect as CustomSelect
import Game.Account.Messages as Account
import Game.Data as Game
import Game.Meta.Messages as Meta
import Game.Servers.Messages as Servers
import OS.Header.Messages exposing (..)
import OS.Header.Models exposing (..)


update : Game.Data -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update data msg ({ openMenu } as model) =
    case msg of
        Logout ->
            let
                dispatch =
                    Dispatch.account Account.Logout
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
                ( model_, Cmd.none, Dispatch.none )

        CustomSelect CustomSelect.MouseEnter ->
            let
                model_ =
                    { model | mouseSomewhereInside = True }
            in
                ( model_, Cmd.none, Dispatch.none )

        CustomSelect CustomSelect.MouseLeave ->
            let
                model_ =
                    { model | mouseSomewhereInside = False }
            in
                ( model_, Cmd.none, Dispatch.none )

        SelectGateway id ->
            let
                dispatch =
                    case id of
                        Just id ->
                            Dispatch.meta <| Meta.SetGateway id

                        Nothing ->
                            Dispatch.none

                model_ =
                    { model | openMenu = NothingOpen }
            in
                ( model_, Cmd.none, dispatch )

        SelectBounce id ->
            let
                dispatch =
                    Dispatch.servers <| Servers.SetBounce data.id id

                model_ =
                    { model | openMenu = NothingOpen }
            in
                ( model_, Cmd.none, dispatch )

        SelectEndpoint ip ->
            let
                dispatch =
                    Dispatch.meta <| Meta.SetEndpoint ip

                model_ =
                    { model | openMenu = NothingOpen }
            in
                ( model_, Cmd.none, dispatch )

        CheckMenus ->
            let
                model_ =
                    if not model.mouseSomewhereInside then
                        { model | openMenu = NothingOpen }
                    else
                        model
            in
                ( model_, Cmd.none, Dispatch.none )

        ContextTo context ->
            let
                dispatch =
                    Dispatch.meta <| Meta.ContextTo context
            in
                ( model, Cmd.none, dispatch )

        NotificationsTabGo target ->
            let
                model_ =
                    { model | activeNotificationsTab = target }
            in
                ( model_, Cmd.none, Dispatch.none )
