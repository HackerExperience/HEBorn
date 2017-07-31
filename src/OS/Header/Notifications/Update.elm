module OS.Header.Notifications.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import OS.Header.Notifications.Models exposing (..)
import OS.Header.Notifications.Messages exposing (..)


update : Game.Data -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update data msg model =
    case msg of
        NotifyAccount content ->
            let
                model_ =
                    notifyAccount content model
            in
                ( model_, Cmd.none, Dispatch.none )

        NotifyChat content ->
            let
                model_ =
                    notifyChat content model
            in
                ( model_, Cmd.none, Dispatch.none )

        NotifyGame origin content ->
            let
                model_ =
                    notifyGame content model
            in
                ( model_, Cmd.none, Dispatch.none )

        Remove id ->
            let
                model_ =
                    remove id model
            in
                ( model_, Cmd.none, Dispatch.none )

        CleanAccount ->
            let
                model_ =
                    cleanAccount model
            in
                ( model_, Cmd.none, Dispatch.none )

        CleanChat ->
            let
                model_ =
                    cleanChat model
            in
                ( model_, Cmd.none, Dispatch.none )

        CleanGame ->
            let
                model_ =
                    cleanGame model
            in
                ( model_, Cmd.none, Dispatch.none )
