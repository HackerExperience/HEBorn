module Utils.Cmd exposing (delay, fromMsg)

import Time
import Task
import Process


delay : Float -> msg -> Cmd msg
delay seconds msg =
    Process.sleep (Time.second * seconds)
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


fromMsg : a -> Cmd a
fromMsg msg =
    Task.perform (always msg) (Task.succeed ())
