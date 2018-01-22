module Events.Account.Handlers.StoryStepProceeded exposing (Data, handler)

import Json.Decode exposing (Decoder, decodeValue, string, field)
import Events.Shared exposing (Handler)


type alias Data =
    String


handler : Handler Data msg
handler toMsg =
    decodeValue stepProceed >> Result.map toMsg



-- internals


stepProceed : Decoder String
stepProceed =
    field "next_step" string
