module Events.Account exposing (Event(..), handler)

import Json.Encode exposing (Value)


type Event
    = NoOp


handler : String -> Value -> Event
handler event value =
    case event of
        _ ->
            eventHandler value



-- internals


eventHandler : Value -> Event
eventHandler value =
    NoOp
