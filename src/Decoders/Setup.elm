module Decoders.Setup exposing (..)

import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , map
        , andThen
        , succeed
        , fail
        , string
        , list
        )
import Json.Decode.Pipeline exposing (decode, required, optional, custom)
import Utils.Json.Decode exposing (commonError)
import Setup.Types as Setup exposing (Step(..))
import Setup.Models as Setup


remainingSteps : Decoder Setup.Steps
remainingSteps =
    map Setup.remainingSteps steps


steps : Decoder Setup.Steps
steps =
    list step


step : Decoder Setup.Step
step =
    andThen stepFromString string


stepFromString : String -> Decoder Setup.Step
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
