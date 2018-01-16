module Core.Subscribers.OS exposing (dispatch)

import Core.Dispatch.OS exposing (..)
import Core.Subscribers.Helpers exposing (..)
import OS.SessionManager.Messages as SessionManager
import OS.SessionManager.WindowManager.Messages as WM


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        OpenApp maybeContext app ->
            [ sessionManager <| SessionManager.OpenApp maybeContext app ]

        CloseApp reference ->
            [ sessionManager <| SessionManager.WindowManagerMsg reference.sessionId (WM.Close reference.windowId) ]
