module Events.Account.Handlers.StoryEmailReplySent exposing (Data, handler)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , andThen
        , float
        , string
        )
import Json.Decode.Pipeline exposing (decode, required, optional)
import Time exposing (Time)
import Events.Shared exposing (Handler)
import Decoders.Storyline exposing (replies, reply, step)
import Game.Storyline.Shared exposing (Reply, Step, ContactId)


type alias Data =
    { timestamp : Time
    , contactId : ContactId
    , step : Step
    , reply : Reply
    , availableReplies : List Reply
    }


handler : Handler Data msg
handler toMsg =
    decodeValue replySent >> Result.map toMsg



-- internals


replySent : Decoder Data
replySent =
    decode Data
        |> required "timestamp" float
        |> required "contact_id" string
        |> required "step" step
        |> required "reply_id" reply
        --|> required "reply_to" reply
        |> required "replies" replies
