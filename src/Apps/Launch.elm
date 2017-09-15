module Apps.Launch exposing (launch)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.Apps exposing (..)
import Apps.Messages exposing (..)
import Apps.Models exposing (..)
import Apps.Config exposing (..)
import Apps.LogViewer.Models as LogViewer
import Apps.TaskManager.Models as TaskManager
import Apps.Browser.Models as Browser
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


launch : Game.Data -> Config -> App -> ( AppModel, Cmd Msg, Dispatch )
launch data ({ windowId } as config) app =
    case app of
        LogViewerApp ->
            let
                model =
                    LogViewerModel LogViewer.initialModel
            in
                ( model, Cmd.none, Dispatch.none )

        TaskManagerApp ->
            let
                model =
                    TaskManagerModel TaskManager.initialModel
            in
                ( model, Cmd.none, Dispatch.none )

        BrowserApp ->
            let
                model =
                    BrowserModel <| Browser.initialModel config
            in
                ( model, Cmd.none, Dispatch.none )

        ExplorerApp ->
            let
                model =
                    ExplorerModel Explorer.initialModel
            in
                ( model, Cmd.none, Dispatch.none )

        DatabaseApp ->
            let
                model =
                    DatabaseModel Database.initialModel
            in
                ( model, Cmd.none, Dispatch.none )

        ConnManagerApp ->
            let
                model =
                    ConnManagerModel ConnManager.initialModel
            in
                ( model, Cmd.none, Dispatch.none )

        BounceManagerApp ->
            let
                model =
                    BounceManagerModel BounceManager.initialModel
            in
                ( model, Cmd.none, Dispatch.none )

        FinanceApp ->
            let
                model =
                    FinanceModel Finance.initialModel
            in
                ( model, Cmd.none, Dispatch.none )

        MusicApp ->
            let
                model =
                    MusicModel <| Hebamp.initialModel windowId
            in
                ( model, Cmd.none, Dispatch.none )

        CtrlPanelApp ->
            let
                model =
                    CtrlPanelModel CtrlPanel.initialModel
            in
                ( model, Cmd.none, Dispatch.none )

        ServersGearsApp ->
            let
                model =
                    ServersGearsModel ServersGears.initialModel
            in
                ( model, Cmd.none, Dispatch.none )

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
            let
                model =
                    LanViewerModel LanViewer.initialModel
            in
                ( model, Cmd.none, Dispatch.none )

        EmailApp ->
            let
                model =
                    EmailModel Email.initialModel
            in
                ( model, Cmd.none, Dispatch.none )
