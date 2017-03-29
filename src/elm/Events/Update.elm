module Events.Update exposing (getEvent)

import Events.Models exposing (Event(..))

getEvent : String -> Event
getEvent rawEvent =
    case rawEvent of
        "mycolevent" ->
            EventMyCool
        _ ->
            EventUnknown
