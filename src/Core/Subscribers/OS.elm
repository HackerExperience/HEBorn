module Core.Subscribers.OS exposing (dispatch)

import Core.Dispatch.OS exposing (..)
import Core.Subscribers.Helpers exposing (..)
import OS.SessionManager.Messages as SessionManager


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        OpenApp a b ->
            [ sessionManager <| SessionManager.OpenApp a b ]

        OpenAppParams a b ->
            [ sessionManager <| SessionManager.HandleOpenAppParams a b ]
