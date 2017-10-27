module Core.Subscribers.Core exposing (dispatch)

import Core.Dispatch.Core exposing (..)
import Core.Subscribers.Helpers exposing (..)
import Core.Messages as Core


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        Boot a b c ->
            [ Core.HandleBoot a b c ]

        Crash a b ->
            [ Core.HandleCrash a b ]

        Shutdown ->
            [ Core.HandleShutdown ]

        Play ->
            [ Core.HandlePlay ]

        _ ->
            []
