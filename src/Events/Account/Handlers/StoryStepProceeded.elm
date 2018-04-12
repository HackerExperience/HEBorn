module Events.Account.Handlers.StoryStepProceeded exposing (Data, handler)

import Json.Decode exposing (Decoder, decodeValue, map, field)
import Events.Shared exposing (Handler)
import Decoders.Storyline exposing (stepWithActions)
import Game.Storyline.Shared exposing (Reply, Quest, Step, ContactId)
import Game.Storyline.StepActions.Shared exposing (Action)


type alias Data =
    { quest : Quest
    , step : Step
    , actions : List Action
    }


handler : Handler Data msg
handler toMsg =
    decodeValue stepProceed >> Result.map toMsg



-- internals


stepProceed : Decoder Data
stepProceed =
    stepWithActions
        |> field "next_step"
        |> map (\( q, s, a ) -> Data q s a)
