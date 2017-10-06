module Events.Account.Inventory exposing (Event(..), handler)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , dict
        )
import Utils.Events exposing (Handler, notify)
import Decoders.Inventory exposing (..)
import Game.Account.Inventory.Models exposing (..)


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
    decodeValue iventory json
        |> Result.map Changed
        |> notify
