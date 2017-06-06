module Game.Servers.Logs.Messages exposing (LogMsg(..))

import Game.Servers.Logs.Models exposing (Data)


type LogMsg
    = UpdateLogs Data
