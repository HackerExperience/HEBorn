module Events.Account.Story.StepProceeded exposing (Data, handler)

import Json.Decode exposing (Decoder, decodeValue, string, field)
import Events.Types exposing (Handler)


type alias Data =
    String


handler : Handler Data event
handler event =
    decodeValue stepProceed >> Result.map event



-- internals


stepProceed : Decoder String
stepProceed =
    field "next_step" string
