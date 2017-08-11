module Events.Account.Bounces exposing (Event(..), handler)

import Utils.Events exposing (Handler)


type Event
    = Changed


handler : String -> Handler Event
handler event json =
    case event of
        "changed" ->
            onChanged json

        _ ->
            Nothing



-- internals


onChanged : Handler Event
onChanged json =
    Just Changed
