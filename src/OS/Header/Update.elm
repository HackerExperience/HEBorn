module OS.Header.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import UI.Widgets.CustomSelect as CustomSelect
import Game.Account.Messages as Account
import Game.Data as Game
import Game.Models as Game
import Game.Meta.Messages as Meta
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers
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
                    Dispatch.meta <| Meta.SetGateway id

                model_ =
                    { model | openMenu = NothingOpen }
            in
                ( model_, Cmd.none, dispatch )

        SelectBounce id ->
            let
                id_ =
                    -- this could be done in a better way
                    if id == "" then
                        Nothing
                    else
                        Just id

                dispatch =
                    Dispatch.servers <| Servers.SetBounce data.id id_

                model_ =
                    { model | openMenu = NothingOpen }
            in
                ( model_, Cmd.none, dispatch )

        SelectEndpoint ip ->
            let
                context =
                    data
                        |> Game.getGame
                        |> Game.getMeta
                        |> (.context)

                id =
                    data
                        |> Game.getGame
                        |> Game.fromGateway
                        |> Maybe.withDefault data
                        |> Game.getID

                ip_ =
                    if ip == "" then
                        Nothing
                    else
                        Just ip

                dispatch =
                    Dispatch.servers <| Servers.SetEndpoint id ip_

                dispatch_ =
                    case ( context, ip_ ) of
                        ( Meta.Endpoint, Nothing ) ->
                            Dispatch.batch
                                [ Dispatch.meta <| Meta.ContextTo Meta.Gateway
                                , dispatch
                                ]

                        _ ->
                            dispatch

                model_ =
                    { model | openMenu = NothingOpen }
            in
                ( model_, Cmd.none, dispatch_ )

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
                endpoint =
                    data
                        |> Game.getServer
                        |> Servers.getEndpoint

                dispatch =
                    case ( endpoint, context ) of
                        ( Nothing, Meta.Endpoint ) ->
                            Dispatch.none

                        _ ->
                            Dispatch.meta <| Meta.ContextTo context
            in
                ( model, Cmd.none, dispatch )
