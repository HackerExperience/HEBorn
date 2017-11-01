module Core.Subscribers.OS exposing (dispatch)

import Core.Dispatch.OS exposing (..)
import Core.Subscribers.Helpers exposing (..)
import Core.Messages as Core
import OS.Messages as OS


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        OpenApp ->
            []
