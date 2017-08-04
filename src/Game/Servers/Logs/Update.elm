module Game.Servers.Logs.Update exposing (..)

import Game.Models as Game
import Game.Messages as Game
import Game.Servers.Logs.Messages as Logs exposing (Msg(..))
import Game.Servers.Logs.Models exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)


update :
    Game.Model
    -> Msg
    -> Logs
    -> ( Logs, Cmd Game.Msg, Dispatch )
update game msg model =
    case msg of
        UpdateContent logId value ->
            let
                model_ =
                    updateContent model logId value
            in
                ( model_, Cmd.none, Dispatch.none )

        Crypt logId ->
            let
                model_ =
                    crypt model logId
            in
                ( model_, Cmd.none, Dispatch.none )

        Uncrypt logId restauredContent ->
            let
                model_ =
                    uncrypt model logId restauredContent
            in
                ( model_, Cmd.none, Dispatch.none )

        Hide logId ->
            let
                model_ =
                    removeById logId model
            in
                ( model_, Cmd.none, Dispatch.none )

        Unhide log ->
            -- TODO
            ( model, Cmd.none, Dispatch.none )

        Delete logId ->
            let
                model_ =
                    removeById logId model
            in
                ( model_, Cmd.none, Dispatch.none )

        _ ->
            (model, Cmd.none, Dispatch.none)