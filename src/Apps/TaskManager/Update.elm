module Apps.TaskManager.Update exposing (update)

import Time exposing (Time)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.React as React exposing (React)
import Game.Servers.Processes.Models as Processes
import Game.Servers.Processes.Messages as Processes
import Apps.TaskManager.Config exposing (..)
import Apps.TaskManager.Models exposing (Model)
import Apps.TaskManager.Messages as TaskManager exposing (Msg(..))
import Apps.TaskManager.Menu.Messages as Menu
import Apps.TaskManager.Menu.Update as Menu
import Apps.TaskManager.Menu.Actions as Menu


type alias UpdateResponse cmd =
    ( Model, React cmd )


update :
    Config msg
    -> TaskManager.Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            let
                config_ =
                    menuConfig config

                ( model_, react ) =
                    Menu.actionHandler config_ action model
            in
                ( model_, react )

        MenuMsg msg ->
            onMenuMsg config msg model

        --- Every update
        Tick now ->
            onTick config now model


onMenuMsg : Config msg -> Menu.Msg -> Model -> UpdateResponse msg
onMenuMsg config msg model =
    let
        config_ =
            menuConfig config

        ( menu_, react ) =
            Menu.update config_ msg model.menu

        model_ =
            { model | menu = menu_ }
    in
        ( model_, react )


onTick : Config msg -> Time -> Model -> UpdateResponse msg
onTick config now model =
    let
        model_ =
            updateTasks
                config
                model
    in
        ( model_, React.none )


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
