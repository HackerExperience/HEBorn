module Game.Servers.Processes.Templates exposing (..)

import Time exposing (Time)
import Game.Servers.Processes.Messages as Processes exposing (Msg(..))
import Game.Servers.Processes.Models exposing (Process, ProcessProp(LocalProcess))
import Game.Servers.Processes.Types.Shared exposing (LogForgeAction(LogCrypt), TargetLogID)
import Game.Servers.Processes.Types.Local as Local exposing (Version, ProcessType(LogForge), ProcessState(StateRunning), ProcessProp)


localLogCrypt : Version -> TargetLogID -> Time -> Processes.Msg
localLogCrypt forgeVersion logId lastTick =
    let
        id =
            "loop" ++ toString (lastTick) ++ "lf"

        task =
            LocalProcess
                (Local.ProcessProp
                    (LogForge forgeVersion logId LogCrypt)
                    3
                    StateRunning
                    (Just (lastTick + 4000))
                    (Just 0)
                    Nothing
                    "localhost"
                    "localhost"
                    Nothing
                    Nothing
                    100000
                    32000
                    0
                    0
                )
    in
        Processes.Create (Process id task)
