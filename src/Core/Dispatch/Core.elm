module Core.Dispatch.Core exposing (..)

{-| Messages related to game's core, like booting, crashing, exiting.
-}


type Dispatch
    = Boot
    | Shutdown
    | Crash
    | Play
    | Exit
