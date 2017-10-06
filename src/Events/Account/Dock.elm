module Events.Account.Dock exposing (Event(..), handler)

import Json.Decode
    exposing
        ( Decoder
        , succeed
        , fail
        , decodeValue
        , andThen
        , list
        , string
        )
import Utils.Events exposing (Handler, notify)
import Game.Account.Dock.Models exposing (..)
import Decoders.Dock exposing (..)


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
    decodeValue dock json
        |> Result.map Changed
        |> notify
