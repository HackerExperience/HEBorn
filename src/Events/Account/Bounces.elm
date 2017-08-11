module Events.Account.Bounces exposing (Event(..), handler, decoder)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , list
        , dict
        , string
        )
import Json.Decode.Pipeline exposing (decode, required)
import Utils.Events exposing (Handler)
import Game.Account.Bounces.Models exposing (..)


type Event
    = Changed


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
    Just Changed


decoder : Decoder Model
decoder =
    dict bounce


bounce : Decoder Bounce
bounce =
    decode Bounce
        |> required "name" string
        |> required "path" (list nip)


nip : Decoder ( String, String )
nip =
    decode (,)
        |> required "netid" string
        |> required "ip" string
