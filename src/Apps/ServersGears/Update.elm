module Apps.ServersGears.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Apps.ServersGears.Config exposing (..)
import Apps.ServersGears.Messages exposing (..)
import Apps.ServersGears.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case getMotherboard model of
        Just motherboard ->
            updateGateway config motherboard msg model

        Nothing ->
            updateEndpoint config msg model



-- gateway-only update


updateGateway :
    Config msg
    -> Motherboard
    -> Msg
    -> Model
    -> UpdateResponse msg
updateGateway config motherboard msg model =
    case msg of
        Save ->
            onSave config motherboard model

        msg ->
            updateGeneric config msg model


onSave : Config msg -> Motherboard -> Model -> UpdateResponse msg
onSave { onMotherboardUpdate } motherboard model =
    motherboard
        |> onMotherboardUpdate
        |> React.msg
        |> (,) model



-- endpoint-only update


updateEndpoint :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse msg
updateEndpoint config msg model =
    updateGeneric config msg model



-- generic update


updateGeneric : Config msg -> Msg -> Model -> UpdateResponse msg
updateGeneric config msg model =
    case msg of
        Select selection ->
            onSelectMsg config selection model

        Unlink ->
            onUnlinkMsg config model

        _ ->
            ( model, React.none )


onSelectMsg : Config msg -> Maybe Selection -> Model -> UpdateResponse msg
onSelectMsg config selection_ model =
    let
        inv =
            config.inventory
    in
        case ( model.motherboard, model.selection, selection_ ) of
            ( Just mobo, Just (SelectingSlot slotA), Just (SelectingSlot slotB) ) ->
                let
                    model_ =
                        swapSlots slotA slotB inv mobo model
                in
                    ( model_, React.none )

            ( Just mobo, Just (SelectingEntry entry), Just (SelectingSlot slot) ) ->
                let
                    model_ =
                        linkSlot slot entry inv mobo model
                in
                    ( model_, React.none )

            ( Just mobo, Just (SelectingSlot slot), Just (SelectingEntry entry) ) ->
                let
                    fixSelection model_ =
                        if model_.selection == model.selection then
                            highlightComponent entry inv selection_ model_
                        else
                            model_

                    model_ =
                        linkSlot slot entry inv mobo model
                            |> fixSelection
                in
                    ( model_, React.none )

            ( Just mobo, _, Just (SelectingSlot slotId) ) ->
                let
                    model_ =
                        highlightSlot slotId mobo selection_ model
                in
                    ( model_, React.none )

            ( _, _, Just (SelectingEntry entry) ) ->
                let
                    model_ =
                        highlightComponent entry inv selection_ model
                in
                    ( model_, React.none )

            _ ->
                let
                    model_ =
                        setSelection selection_ Nothing model
                in
                    ( model_, React.none )


onUnlinkMsg : Config msg -> Model -> UpdateResponse msg
onUnlinkMsg config model =
    case model.selection of
        Just (SelectingSlot slot) ->
            let
                inv =
                    config.inventory

                model_ =
                    unlinkSlot slot inv model
            in
                ( model_, React.none )

        _ ->
            let
                model_ =
                    removeSelection model
            in
                ( model_, React.none )
