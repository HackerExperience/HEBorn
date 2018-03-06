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
    Dict RequestId (Dict String msg)


type alias RequestId =
    String


empty : AwaitEvent msg
empty =
    Dict.empty


subscribe :
    RequestId
    -> ( String, msg )
    -> AwaitEvent msg
    -> AwaitEvent msg
subscribe requestId event awaitEvent =
    let
        msgs =
            Maybe.withDefault Dict.empty <| Dict.get requestId awaitEvent

        insertEffect ( eventName, effectMsg ) dict =
            dict
                |> Dict.insert eventName effectMsg
                |> flip (Dict.insert requestId) awaitEvent
    in
        insertEffect event msgs


receive : String -> RequestId -> AwaitEvent msg -> ( Maybe msg, AwaitEvent msg )
receive eventName requestId awaitEvent =
    ( Maybe.andThen (Dict.get eventName) (Dict.get requestId awaitEvent)
    , Dict.remove requestId awaitEvent
    )
