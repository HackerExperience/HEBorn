module Events.Account.Story.Completed exposing (Data, handler)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , map
        , andThen
        , field
        , list
        , bool
        )
import Json.Decode.Pipeline exposing (decode, required, optional)
import Events.Types exposing (Handler)
import Decoders.Emails exposing (contentFromId)


type alias Data =
    { completed : Bool }


handler : Handler Data event
handler event =
    decodeValue tutorialFinished >> Result.map event



-- internals


tutorialFinished : Decoder Data
tutorialFinished =
    decode Data
        |> required "tutorial_complete" bool
