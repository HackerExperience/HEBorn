module Game.Servers.Logs.Update exposing (update, bootstrap)

import Json.Decode exposing (Value, decodeValue, list)
import Game.Models as Game
import Game.Servers.Logs.Messages as Logs exposing (Msg(..))
import Game.Servers.Logs.Models exposing (..)
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

        _ ->
            ( model, Cmd.none, Dispatch.none )


bootstrap : Value -> Logs -> Logs
bootstrap json model =
    let
        mapper data =
            let
                log =
                    StdLog <|
                        (StdData data.id
                            StatusNormal
                            data.insertedAt
                            data.message
                            (interpretRawContent data.message)
                            NoEvent
                        )
            in
                ( data.id, log )

        insert id item model =
            -- TODO: actually insert the logs
            model
    in
        -- TODO: actually appply the new index
        model
