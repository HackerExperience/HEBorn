module Core.Dispatch.OS exposing (..)

import Game.Meta.Types.Context exposing (Context)
import Apps.Apps exposing (App)
import Apps.Reference exposing (Reference)
import Apps.Apps exposing (App, AppParams)


{-| Messages related to the running operational system, should be generic
enough to be used by other operational systems.
-}
type Dispatch
    = NewApp (Maybe Context) (Maybe AppParams) App
    | OpenApp (Maybe Context) AppParams
    | CloseApp Reference
