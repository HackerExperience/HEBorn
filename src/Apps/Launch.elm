module Apps.Launch exposing (launch, launchEvent)

import Game.Meta.Types.Context exposing (Context)
import Utils.React as React exposing (React)
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
import Apps.BounceManager.Messages as BounceManager
import Apps.BounceManager.Launch as BounceManager
import Apps.Finance.Models as Finance
import Apps.Hebamp.Launch as Hebamp
import Apps.Hebamp.Messages as Hebamp
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
    -> ( AppModel, React msg )
launch config ({ windowId } as reference) maybeParams app =
    case app of
        LogViewerApp ->
            LogViewer.initialModel
                |> LogViewerModel
                |> flip (,) React.none

        TaskManagerApp ->
            TaskManager.initialModel
                |> TaskManagerModel
                |> flip (,) React.none

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

                ( model, react ) =
                    Browser.launch config_ params reference

                model_ =
                    BrowserModel model
            in
                ( model_, react )

        ExplorerApp ->
            Explorer.initialModel
                |> ExplorerModel
                |> flip (,) React.none

        DatabaseApp ->
            Database.initialModel
                |> DatabaseModel
                |> flip (,) React.none

        ConnManagerApp ->
            ConnManager.initialModel
                |> ConnManagerModel
                |> flip (,) React.none

        BounceManagerApp ->
            let
                config_ =
                    bounceManConfig config

                params =
                    case maybeParams of
                        Just (BounceManagerParams params) ->
                            Just params

                        _ ->
                            Nothing

                ( model, react ) =
                    BounceManager.launch config_ params reference

                model_ =
                    BounceManagerModel model
            in
                ( model_, react )

        FinanceApp ->
            Finance.initialModel
                |> FinanceModel
                |> flip (,) React.none

        MusicApp ->
            let
                config_ =
                    hebampConfig config

                params =
                    case maybeParams of
                        Just (MusicParams params) ->
                            Just params

                        _ ->
                            Nothing

                ( model, react ) =
                    Hebamp.launch config_ params reference

                model_ =
                    MusicModel model
            in
                ( model_, react )

        CtrlPanelApp ->
            CtrlPanel.initialModel
                |> CtrlPanelModel
                |> flip (,) React.none

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
                    |> flip (,) React.none

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
                ( model, React.map config.toMsg <| React.cmd cmd )

        LanViewerApp ->
            LanViewer.initialModel
                |> LanViewerModel
                |> flip (,) React.none

        EmailApp ->
            Email.initialModel
                |> EmailModel
                |> flip (,) React.none

        BugApp ->
            Bug.initialModel
                |> BugModel
                |> flip (,) React.none

        CalculatorApp ->
            Calculator.initialModel
                |> CalculatorModel
                |> flip (,) React.none

        BackFlixApp ->
            BackFlix.initialModel
                |> BackFlixModel
                |> flip (,) React.none

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

                ( model, react ) =
                    FloatingHeads.launch config_ params reference

                model_ =
                    FloatingHeadsModel model
            in
                ( model_, react )


launchEvent : Context -> AppParams -> Msg
launchEvent context params =
    case params of
        BrowserParams params ->
            BrowserMsg <| Browser.LaunchApp context params

        FloatingHeadsParams params ->
            FloatingHeadsMsg <| FloatingHeads.LaunchApp context params

        MusicParams params ->
            MusicMsg <| Hebamp.LaunchApp context params

        BounceManagerParams params ->
            BounceManagerMsg <| BounceManager.LaunchApp context params
