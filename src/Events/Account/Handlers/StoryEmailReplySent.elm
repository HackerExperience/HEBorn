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
import Decoders.Storyline exposing (replies, reply, stepWithActions)
import Game.Storyline.Shared exposing (Reply, Quest, Step, ContactId)
import Game.Storyline.StepActions.Shared exposing (Action)


type alias Data =
    { timestamp : Time
    , contactId : ContactId
    , step : ( Quest, Step, List Action )
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
        |> required "step" stepWithActions
        |> required "reply_id" reply
        --|> required "reply_to" reply
        |> required "replies" replies
