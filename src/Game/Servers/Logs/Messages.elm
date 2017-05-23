module Game.Servers.Logs.Messages exposing (LogMsg(..))

import Game.Servers.Logs.Models exposing (LogData)


type LogMsg
    = UpdateLogs LogData
