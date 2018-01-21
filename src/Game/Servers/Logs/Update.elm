module Game.Servers.Logs.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Servers.Logs.Config exposing (..)
import Game.Servers.Logs.Messages exposing (..)
import Game.Servers.Logs.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandleCreated id log ->
            ( insert id log model, React.none )

        HandleUpdateContent id content ->
            updateLog (setContent <| Just content) id model

        HandleHide id ->
            ( model, React.none )

        HandleEncrypt id ->
            updateLog (setContent Nothing) id model

        HandleDecrypt id content ->
            updateLog (setContent <| Just content) id model

        HandleDelete id ->
            ( model, React.none )


updateLog : (Log -> Log) -> ID -> Model -> UpdateResponse msg
updateLog func id model =
    case get id model of
        Just log ->
            ( insert id (func log) model, React.none )

        Nothing ->
            ( model, React.none )
