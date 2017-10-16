module Events.Account.Story.NewEmail exposing (Data, handler)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , string
        , float
        , field
        , map
        , andThen
        )
import Json.Decode.Pipeline exposing (decode, required, custom)
import Events.Types exposing (Handler)
import Decoders.Emails
import Game.Storyline.Emails.Models exposing (..)
import Game.Storyline.Emails.Contents exposing (..)


type alias Data =
    ( String, ( Float, Message ), List Content )


handler : Handler Data event
handler event =
    decodeValue newEmail >> Result.map (toData >> event)



-- internals


{-| TODO: fix this
-}
toData : ( Float, Message ) -> Data
toData msg =
    ( "TODO", msg, [] )


newEmail : Decoder ( Float, Message )
newEmail =
    decode (,)
        |> required "timestamp" float
        |> custom message


message : Decoder Message
message =
    field "email_id" string
        |> andThen Decoders.Emails.contentFromId
        |> map Received
