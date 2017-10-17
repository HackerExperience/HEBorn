module Decoders.Setup exposing (..)

import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , andThen
        , map
        , oneOf
        , succeed
        , fail
        , string
        , float
        , value
        , field
        , list
        )
import Json.Decode.Pipeline exposing (decode, required, optional, custom)
import Utils.Json.Decode exposing (commonError)
import Setup.Models exposing (..)


steps : Steps
steps =
    list step


step : Decoder Step
step =
    andThen pageFromString string


stepFromString : String -> Decoder Step
stepFromString str =
    case str of
        "welcome" ->
            succeed Welcome

        "pick_location" ->
            succeed PickLocation

        "choose_theme" ->
            succeed ChooseTheme

        "finish" ->
            succeed Finish

        _ ->
            fail <| commonError "Step" str
