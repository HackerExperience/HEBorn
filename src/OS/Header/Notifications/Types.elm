module OS.Header.Notifications.Types
    exposing
        ( Account
        , Chat
        , Game
        , Origin
        , Content
        , ID
        )

import Apps.Apps as Apps
import Game.Meta.Messages exposing (Context(..))
import Utils.Model.RandomUuid as RandomUuid


type alias Account =
    { content : String }


type alias Chat =
    { content : String }


type alias Game =
    { origin : Maybe Origin
    , content : String
    }


type alias Origin =
    { app : Apps.App
    , context : Context
    }


type alias Content =
    String


type alias ID =
    RandomUuid.Uuid
