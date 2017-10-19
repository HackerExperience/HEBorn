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
import Setup.Types as Setup exposing (Page(..))
import Setup.Models as Setup


remainingPages : Decoder Setup.Pages
remainingPages =
    map Setup.remainingPages pages


pages : Decoder Setup.Pages
pages =
    list page


page : Decoder Setup.Page
page =
    andThen pageFromString string


pageFromString : String -> Decoder Setup.Page
pageFromString str =
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
            fail <| commonError "Setup.Models.Page" str
