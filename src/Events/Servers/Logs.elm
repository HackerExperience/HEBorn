module Events.Servers.Logs exposing (Event(..), handler)

import Json.Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , list
        , maybe
        , string
        , float
        )
import Json.Decode.Pipeline exposing (required, decode)
import Time exposing (Time)
import Utils.Events exposing (Handler)


type Event
    = Changed Index


type alias Index =
    List Log


type alias Log =
    { id : String
    , message : Maybe String
    , insertedAt : Time
    }


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
    case decodeValue index json of
        Ok data ->
            Just <| Changed data

        Err str ->
            Debug.log ("▶ Event parse error " ++ str) Nothing


index : Decoder Index
index =
    list log


log : Decoder Log
log =
    decode Log
        |> required "log_id" string
        |> required "message" (maybe string)
        |> required "inserted_at" float
