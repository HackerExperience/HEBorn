module Events.Account.Bounces exposing (Event(..), handler)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , list
        , dict
        , string
        )
import Json.Decode.Pipeline exposing (decode, required)
import Utils.Events exposing (Handler, notify)
import Decoders.Bounces exposing (..)
import Game.Account.Bounces.Models exposing (..)


type Event
    = Changed Model


handler : String -> Handler Event
handler event json =
    case event of
        "changed" ->
            onChanged json

        _ ->
            Nothing



-- internals


onChanged : Handler Event
onChanged json =
    decodeValue bounces json
        |> Result.map Changed
        |> notify
