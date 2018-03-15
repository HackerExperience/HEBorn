module Game.Account.Bounces.Update exposing (update)

import Dict
import Utils.React as React exposing (React)
import Game.Account.Bounces.Config exposing (..)
import Game.Account.Bounces.Messages exposing (..)
import Game.Account.Bounces.Models exposing (..)
import Game.Account.Bounces.Shared exposing (..)
import Game.Meta.Types.Desktop.Apps exposing (Reference)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandleCreated requestId id bounce ->
            handleCreated config requestId id bounce model

        HandleUpdated id bounce ->
            handleUpdated config id bounce model

        HandleRemoved id ->
            handleDeleted config id model

        HandleWaitForBounce requestId ref ->
            handleWaitForBounce config requestId ref model

        HandleRequestReload id ref ->
            handleRequestReload config id ref model


handleCreated :
    Config msg
    -> String
    -> ID
    -> Bounce
    -> Model
    -> UpdateResponse msg
handleCreated config requestId id bounce model =
    let
        removeRef model =
            case Dict.get requestId model.optimistics of
                Just ref ->
                    { model | optimistics = Dict.remove ref model.optimistics }

                Nothing ->
                    model

        model_ =
            model
                |> insert id bounce
                |> removeRef

        react =
            case Dict.get requestId model.optimistics of
                Just ref ->
                    React.msg (config.onReloadBounce id ref)

                Nothing ->
                    React.none
    in
        ( model_, react )


handleUpdated :
    Config msg
    -> ID
    -> Bounce
    -> Model
    -> UpdateResponse msg
handleUpdated config id bounce model =
    ( insert id bounce model, React.none )


handleDeleted : Config msg -> ID -> Model -> UpdateResponse msg
handleDeleted config id model =
    ( remove id model, React.none )


handleWaitForBounce :
    Config msg
    -> String
    -> Reference
    -> Model
    -> UpdateResponse msg
handleWaitForBounce config requestId ref model =
    ( subscribeFor requestId ref model, React.none )


handleRequestReload :
    Config msg
    -> ID
    -> Reference
    -> Model
    -> UpdateResponse msg
handleRequestReload { onReloadBounce } id ref model =
    ( model, React.msg <| onReloadBounce id ref )
