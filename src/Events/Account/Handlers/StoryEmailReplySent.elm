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
import Decoders.Emails exposing (contentFromId)
import Game.Storyline.Emails.Contents exposing (Content)


type alias Data =
    { timestamp : Time
    , step : String
    , replyTo : String
    , content : Content
    , contactId : String
    }


handler : Handler Data msg
handler toMsg =
    decodeValue replySent >> Result.map toMsg



-- internals


replySent : Decoder Data
replySent =
    decode Data
        |> required "timestamp" float
        |> required "step" string
        |> required "reply_to" string
        |> required "reply_id" reply
        |> optional "contact_id" string "friend"


reply : Decoder Content
reply =
    andThen contentFromId string
