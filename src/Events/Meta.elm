module Events.Meta exposing (Event(..), handler)

import Utils.Events exposing (Router)


type Event
    = Event


handler : Router Event
handler event json =
    case event of
        _ ->
            Nothing
