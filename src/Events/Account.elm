module Events.Account
    exposing
        ( Model
        , Event(..)
        , Response(..)
        , events
        , handler
        )

import Json.Encode exposing (Value)


type Event
    = Event


type alias Model =
    List ( String, Event )


type Response
    = EventResponse


events : Model
events =
    [ ( "event", Event ) ]


handler : Event -> Value -> Response
handler event value =
    case event of
        Event ->
            eventHandler value



-- internals


eventHandler : Value -> Response
eventHandler value =
    EventResponse
