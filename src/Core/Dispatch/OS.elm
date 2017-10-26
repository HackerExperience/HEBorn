module Core.Dispatch.OS exposing (..)

{-| Messages related to the running operational system, should be generic
enough to be used by other operational systems.
-}


type Dispatch
    = ToggleCampaign
    | NotifyAccount
    | ReadAccount
    | NotifyServer
    | ReadServer
    | GotoApp
    | OpenAPp
