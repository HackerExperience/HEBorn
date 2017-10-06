module Events.Storyline.Missions exposing (Event(..), handler)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , field
        , string
        )
import Utils.Events exposing (Handler, notify)


type Event
    = StepProceed String


handler : String -> Handler Event
handler event json =
    case event of
        "story_step_proceeded" ->
            onStepProceed json

        _ ->
            Nothing



-- internals


onStepProceed : Handler Event
onStepProceed json =
    decodeValue stepProceed json
        |> Result.map StepProceed
        |> notify


stepProceed : Decoder String
stepProceed =
    field "next_step" string
