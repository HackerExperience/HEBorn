module Events.Update exposing (getEvent)

import Events.Models exposing (Event(..))


getEvent : String -> Event
getEvent rawEvent =
    case rawEvent of
        "mycoolevent" ->
            EventMyCool

        _ ->
            Debug.log rawEvent
                EventUnknown
