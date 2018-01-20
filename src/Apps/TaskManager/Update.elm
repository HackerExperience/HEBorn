module Apps.TaskManager.Update exposing (update)

import Time exposing (Time)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Servers.Shared as Servers
import Game.Servers.Models as Servers
import Game.Servers.Processes.Models as Processes
import Game.Servers.Processes.Messages as Processes
import Apps.TaskManager.Config exposing (..)
import Apps.TaskManager.Models exposing (Model)
import Apps.TaskManager.Messages as TaskManager exposing (Msg(..))
import Apps.TaskManager.Menu.Messages as Menu
import Apps.TaskManager.Menu.Update as Menu
import Apps.TaskManager.Menu.Actions as Menu


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update :
    Config msg
    -> TaskManager.Msg
    -> Model
    -> UpdateResponse
update config msg model =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler config action model

        MenuMsg msg ->
            onMenuMsg config msg model

        --- Every update
        Tick now ->
            onTick config now model


onMenuMsg : Config msg -> Menu.Msg -> Model -> UpdateResponse
onMenuMsg config msg model =
    let
        ( menu_, cmd, coreMsg ) =
            Menu.update config msg model.menu

        cmd_ =
            Cmd.map MenuMsg cmd

        model_ =
            { model | menu = menu_ }
    in
        ( model_, cmd_, coreMsg )


onTick : Config msg -> Time -> Model -> UpdateResponse
onTick config now model =
    let
        activeServer =
            config.activeCId

        model_ =
            updateTasks
                activeServer
                model
    in
        ( model_, Cmd.none, Dispatch.none )


updateTasks : Config msg -> Model -> Model
updateTasks config old =
    let
        tasks =
            config.processes

        reduce process sum =
            process
                |> Processes.getUsage
                |> Maybe.map (flip taskUsageSum sum)
                |> Maybe.withDefault sum

        ( cpu, mem, down, up ) =
            tasks
                |> Processes.values
                |> List.foldr reduce ( 0.0, 0.0, 0.0, 0.0 )

        historyCPU =
            (increaseHistory cpu old.historyCPU)

        historyMem =
            (increaseHistory mem old.historyMem)

        historyDown =
            (increaseHistory down old.historyDown)

        historyUp =
            (increaseHistory up old.historyUp)
    in
        Model
            old.menu
            historyCPU
            historyMem
            historyDown
            historyUp


taskUsageSum :
    Processes.ResourcesUsage
    -> ( Float, Float, Float, Float )
    -> ( Float, Float, Float, Float )
taskUsageSum { cpu, mem, down, up } ( acuCpu, acuMem, acuDown, acuUp ) =
    ( acuCpu + (Processes.getPercentUsage cpu)
    , acuMem + (Processes.getPercentUsage mem)
    , acuDown + (Processes.getPercentUsage down)
    , acuUp + (Processes.getPercentUsage up)
    )


increaseHistory : a -> List a -> List a
increaseHistory new old =
    new :: (List.take 19 old)
