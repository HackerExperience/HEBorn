module Game.Servers.Logs.Update exposing (..)

import Json.Decode as Decode
import Game.Models as Game
import Game.Messages as Game
import Game.Servers.Logs.Messages as Logs exposing (Msg(..))
import Game.Servers.Logs.Models exposing (..)
import Game.Servers.Logs.Requests.LogIndex as LogIndex
import Core.Dispatch as Dispatch exposing (Dispatch)


update :
    Game.Model
    -> Msg
    -> Logs
    -> ( Logs, Cmd Msg, Dispatch )
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

        Bootstrap json ->
            case LogIndex.decoder json of
                Ok logs ->
                    let
                        reducer log model =
                            let
                                log_ =
                                    StdLog <|
                                        (StdData log.id
                                            StatusNormal
                                            log.insertedAt
                                            log.message
                                            (interpretRawContent log.message)
                                            NoEvent
                                        )
                            in
                                add log_ model
                    in
                        let
                            model_ =
                                List.foldl reducer model logs
                        in
                            ( model_, Cmd.none, Dispatch.none )

                Err _ ->
                    ( model, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )
