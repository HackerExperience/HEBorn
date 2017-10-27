module Core.Dispatch.Core exposing (..)

{-| Messages related to game's core, like booting, crashing, exiting.

Boot:

  - Account id
  - Account username
  - Account token

Crash:

  - Error core
  - Error message

-}


type Dispatch
    = Boot String String String
    | Shutdown
    | Crash String String
    | Play
    | Exit
