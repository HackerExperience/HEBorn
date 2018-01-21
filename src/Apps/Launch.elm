module Apps.Launch exposing (launch, launchEvent)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Meta.Types.Context exposing (Context)
import Utils.Update as Update
import Apps.Apps exposing (..)
import Apps.Config exposing (..)
import Apps.Messages exposing (..)
import Apps.Models exposing (..)
import Apps.Reference exposing (..)
import Apps.LogViewer.Models as LogViewer
import Apps.TaskManager.Models as TaskManager
import Apps.Browser.Launch as Browser
import Apps.Browser.Messages as Browser
import Apps.Explorer.Models as Explorer
import Apps.DBAdmin.Models as Database
import Apps.ConnManager.Models as ConnManager
import Apps.BounceManager.Models as BounceManager
import Apps.Finance.Models as Finance
import Apps.Hebamp.Models as Hebamp
import Apps.CtrlPanel.Models as CtrlPanel
import Apps.ServersGears.Models as ServersGears
import Apps.LocationPicker.Models as LocationPicker
import Apps.LanViewer.Models as LanViewer
import Apps.Email.Models as Email
import Apps.Bug.Models as Bug
import Apps.Calculator.Models as Calculator
import Apps.BackFlix.Models as BackFlix
import Apps.FloatingHeads.Messages as FloatingHeads
import Apps.FloatingHeads.Launch as FloatingHeads


launch :
    Config msg
    -> Reference
    -> Maybe AppParams
    -> App
    -> ( AppModel, Cmd Msg, Dispatch )
launch config ({ windowId } as reference) maybeParams app =
    case app of
        LogViewerApp ->
            LogViewer.initialModel
                |> LogViewerModel
                |> Update.fromModel

        TaskManagerApp ->
            TaskManager.initialModel
                |> TaskManagerModel
                |> Update.fromModel

        BrowserApp ->
            let
                config_ =
                    browserConfig config

                params =
                    case maybeParams of
                        Just (BrowserParams params) ->
                            Just params

                        _ ->
                            Nothing

                ( model, cmd, dispatch ) =
                    Browser.launch config_ params reference

                model_ =
                    BrowserModel model

                cmd_ =
                    Cmd.map BrowserMsg cmd
            in
                ( model_, cmd_, dispatch )

        ExplorerApp ->
            Explorer.initialModel
                |> ExplorerModel
                |> Update.fromModel

        DatabaseApp ->
            Database.initialModel
                |> DatabaseModel
                |> Update.fromModel

        ConnManagerApp ->
            ConnManager.initialModel
                |> ConnManagerModel
                |> Update.fromModel

        BounceManagerApp ->
            BounceManager.initialModel
                |> BounceManagerModel
                |> Update.fromModel

        FinanceApp ->
            Finance.initialModel
                |> FinanceModel
                |> Update.fromModel

        MusicApp ->
            Hebamp.initialModel windowId []
                |> MusicModel
                |> Update.fromModel

        CtrlPanelApp ->
            CtrlPanel.initialModel
                |> CtrlPanelModel
                |> Update.fromModel

        ServersGearsApp ->
            let
                config_ =
                    serversGearsConfig config

                mobo =
                    config_.mobo
            in
                mobo
                    |> ServersGears.initialModel
                    |> ServersGearsModel
                    |> Update.fromModel

        LocationPickerApp ->
            let
                pureModel =
                    LocationPicker.initialModel windowId

                model =
                    LocationPickerModel pureModel

                cmd =
                    LocationPicker.startCmd pureModel
                        |> Cmd.map LocationPickerMsg
            in
                ( model, cmd, Dispatch.none )

        LanViewerApp ->
            LanViewer.initialModel
                |> LanViewerModel
                |> Update.fromModel

        EmailApp ->
            Email.initialModel
                |> EmailModel
                |> Update.fromModel

        BugApp ->
            Bug.initialModel
                |> BugModel
                |> Update.fromModel

        CalculatorApp ->
            Calculator.initialModel
                |> CalculatorModel
                |> Update.fromModel

        BackFlixApp ->
            BackFlix.initialModel
                |> BackFlixModel
                |> Update.fromModel

        FloatingHeadsApp ->
            let
                config_ =
                    floatingHeadsConfig config

                params =
                    case maybeParams of
                        Just (FloatingHeadsParams params) ->
                            Just params

                        _ ->
                            Nothing

                ( model, cmd, dispatch ) =
                    FloatingHeads.launch config_ params reference

                model_ =
                    FloatingHeadsModel model

                cmd_ =
                    Cmd.map FloatingHeadsMsg cmd
            in
                ( model_, cmd_, dispatch )


launchEvent : Context -> AppParams -> Msg
launchEvent context params =
    case params of
        BrowserParams params ->
            BrowserMsg <| Browser.LaunchApp context params

        FloatingHeadsParams params ->
            FloatingHeadsMsg <| FloatingHeads.LaunchApp context params
