module Events.Config exposing (..)

import Events.Account.Config as Account
import Events.Server.Config as Server
import Events.BackFlix.Config as BackFlix
import Events.Bank.Config as Bank


type alias Config msg =
    { forAccount : Account.Config msg
    , forServer : Server.Config msg
    , forBackFlix : BackFlix.Config msg
    , forBank : Bank.Config msg
    }
