module Apps.Browser.Menu.Actions exposing (actionHandler)

import Game.Data as Game
import Apps.Browser.Models exposing (..)
import Apps.Browser.Messages exposing (Msg)
import Apps.Browser.Menu.Messages exposing (MenuAction(..))
import Core.Dispatch as Dispatch exposing (Dispatch)


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
actionHandler data action model =
    case action of
        NewTab ->
            let
                model_ =
                    addTab model
            in
                ( model_, Cmd.none, Dispatch.none )

        DeleteTab n ->
            let
                model_ =
                    deleteTab n model
            in
                ( model_, Cmd.none, Dispatch.none )

        GoPrevious ->
            let
                tab_ =
                    gotoPreviousPage <| getNowTab model

                model_ =
                    setNowTab tab_ model
            in
                ( model_, Cmd.none, Dispatch.none )

        GoNext ->
            let
                tab_ =
                    gotoNextPage <| getNowTab model

                model_ =
                    setNowTab tab_ model
            in
                ( model_, Cmd.none, Dispatch.none )

        GoHome ->
            let
                app =
                    getNowTab model

                tab_ =
                    gotoPage "about:blank" BlankModel app

                model_ =
                    setNowTab tab_ model
            in
                ( model_, Cmd.none, Dispatch.none )
