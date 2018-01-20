module Game.Servers.Logs.Update exposing (update)

import Game.Servers.Logs.Config exposing (..)
import Game.Servers.Logs.Messages exposing (..)
import Game.Servers.Logs.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandleCreated id log ->
            ( insert id log model, Cmd.none )

        HandleUpdateContent id content ->
            updateLog (setContent <| Just content) id model

        HandleHide id ->
            ( model, Cmd.none )

        HandleEncrypt id ->
            updateLog (setContent Nothing) id model

        HandleDecrypt id content ->
            updateLog (setContent <| Just content) id model

        HandleDelete id ->
            ( model, Cmd.none )


updateLog : (Log -> Log) -> ID -> Model -> UpdateResponse msg
updateLog func id model =
    case get id model of
        Just log ->
            ( insert id (func log) model, Cmd.none )

        Nothing ->
            ( model, Cmd.none )
