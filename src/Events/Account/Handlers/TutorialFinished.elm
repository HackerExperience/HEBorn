module Events.Account.Handlers.TutorialFinished exposing (Data, handler)

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
import Events.Shared exposing (Handler)


type alias Data =
    { completed : Bool }


handler : Handler Data msg
handler toMsg =
    decodeValue tutorialFinished >> Result.map toMsg



-- internals


tutorialFinished : Decoder Data
tutorialFinished =
    decode Data
        |> required "tutorial_complete" bool
