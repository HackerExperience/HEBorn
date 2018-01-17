module Core.Subscribers.OS exposing (dispatch)

import Core.Dispatch.OS exposing (..)
import Core.Subscribers.Helpers exposing (..)
import OS.SessionManager.Messages as SessionManager
import OS.SessionManager.WindowManager.Messages as WM


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        NewApp a b c ->
            [ sessionManager <| SessionManager.HandleNewApp a b c ]

        OpenApp a b ->
            [ sessionManager <| SessionManager.HandleOpenApp a b ]

        CloseApp a ->
            -- this is probably leaking too much information
            [ sessionManager <|
                SessionManager.WindowManagerMsg
                    a.sessionId
                    (WM.Close a.windowId)
            ]
