module OS.Notifications.Messages exposing (..)

import OS.Notifications.Types exposing (..)


type Msg
    = NotifyAccount Content
    | NotifyChat Content
    | NotifyGame (Maybe Origin) Content
