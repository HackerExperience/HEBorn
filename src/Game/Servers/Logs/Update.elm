module Game.Servers.Logs.Update exposing (..)

import Core.Messages as Core
import Game.Models as Game
import Game.Messages as Game
import Game.Servers.Logs.Messages as Logs exposing (Msg(..))
import Game.Servers.Logs.Models exposing (..)


update :
    Msg
    -> Logs
    -> Game.Model
    -> ( Logs, Cmd Game.Msg, List Core.Msg )
update msg model game =
    case msg of
        UpdateContent logId value ->
            let
                model_ =
                    updateContent model logId value
            in
                ( model_, Cmd.none, [] )

        Crypt logId ->
            let
                model_ =
                    crypt model logId
            in
                ( model_, Cmd.none, [] )

        Uncrypt logId restauredContent ->
            let
                model_ =
                    uncrypt model logId restauredContent
            in
                ( model_, Cmd.none, [] )

        Hide logId ->
            let
                model_ =
                    removeById logId model
            in
                ( model_, Cmd.none, [] )

        Unhide log ->
            -- TODO
            ( model, Cmd.none, [] )

        Delete logId ->
            let
                model_ =
                    removeById logId model
            in
                ( model_, Cmd.none, [] )
