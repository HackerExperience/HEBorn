module Game.Account.Bounces.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Account.Bounces.Config exposing (..)
import Game.Account.Bounces.Messages exposing (..)
import Game.Account.Bounces.Models exposing (..)
import Game.Account.Bounces.Shared exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandleCreated id bounce ->
            handleCreated config id bounce model

        HandleUpdated id bounce ->
            handleUpdated config id bounce model

        HandleRemoved id ->
            handleDeleted config id model


handleCreated :
    Config msg
    -> ID
    -> Bounce
    -> Model
    -> UpdateResponse msg
handleCreated config id bounce model =
    let
        model_ =
            insert id bounce model
    in
        ( model_, React.none )


handleUpdated :
    Config msg
    -> ID
    -> Bounce
    -> Model
    -> UpdateResponse msg
handleUpdated config id bounce model =
    let
        model_ =
            insert id bounce model
    in
        ( model_, React.none )


handleDeleted : Config msg -> ID -> Model -> UpdateResponse msg
handleDeleted config id model =
    let
        model_ =
            remove id model
    in
        ( model_, React.none )
