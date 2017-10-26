module Core.Dispatch.Websocket exposing (..)

{-| Messages related to the websocket driver.
-}


type Dispatch
    = Connected
    | Disconnected
    | Joined
    | Leaved
    | Event
