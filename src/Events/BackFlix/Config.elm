module Events.BackFlix.Config exposing (..)

import Events.BackFlix.Handlers.NewLog as NewLog


type alias Config msg =
    { onNewLog : NewLog.Data -> msg
    }
