module Apps.Browser.Menu.Actions exposing (actionHandler)

import Game.Data as Game
import Apps.Browser.Models exposing (..)
import Apps.Browser.Messages exposing (Msg)
import Apps.Browser.Pages.Models as Pages
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
                app_ =
                    gotoPreviousPage <| getApp model

                model_ =
                    setApp app_ model
            in
                ( model_, Cmd.none, Dispatch.none )

        GoNext ->
            let
                app_ =
                    gotoNextPage <| getApp model

                model_ =
                    setApp app_ model
            in
                ( model_, Cmd.none, Dispatch.none )

        GoHome ->
            let
                app =
                    getApp model

                app_ =
                    gotoPage "about:blank" Pages.BlankModel app

                model_ =
                    setApp app_ model
            in
                ( model_, Cmd.none, Dispatch.none )
