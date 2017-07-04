module OS.Header.Update exposing (update)

import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Account.Messages as Account
import Game.Models as Game


update : Game.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update game msg model =
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
                    if (model.openMenu /= NothingOpen && model.openMenu == next) then
                        NothingOpen
                    else
                        next

                model_ =
                    { model | openMenu = openMenu_ }
            in
                ( model_, Cmd.none, Dispatch.none )

        MouseEnterItem ->
            let
                model_ =
                    { model | mouseSomewhereInside = True }
            in
                ( model_, Cmd.none, Dispatch.none )

        MouseLeaveItem ->
            let
                model_ =
                    { model | mouseSomewhereInside = False }
            in
                ( model_, Cmd.none, Dispatch.none )

        CheckMenus ->
            let
                model_ =
                    if not model.mouseSomewhereInside then
                        { model | openMenu = NothingOpen }
                    else
                        model
            in
                ( model_, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )
