module Game.Meta.Types.AwaitEvent
    exposing
        ( AwaitEvent
        , RequestId
        , empty
        , subscribe
        , receive
        )

import Dict exposing (Dict)


type alias AwaitEvent msg =
    Dict RequestId msg


type alias RequestId =
    String


empty : AwaitEvent msg
empty =
    Dict.empty


subscribe : RequestId -> msg -> AwaitEvent msg -> AwaitEvent msg
subscribe =
    Dict.insert


receive : RequestId -> AwaitEvent msg -> ( Maybe msg, AwaitEvent msg )
receive requestId awaitEvent =
    ( Dict.get requestId awaitEvent
    , Dict.remove requestId awaitEvent
    )
