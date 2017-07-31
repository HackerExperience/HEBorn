module Apps.Models
    exposing
        ( AppModel(..)
        , Contexts(..)
        , contexts
        , name
        , title
        , icon
        , model
        , isDecorated
        )

import Apps.Messages exposing (..)
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
import Apps.Apps exposing (..)
import Apps.Messages exposing (..)
import Game.Data as Game
import Core.Dispatch as Dispatch exposing (Dispatch)


type AppModel
    = LogViewerModel LogViewer.Model
    | TaskManagerModel TaskManager.Model
    | BrowserModel Browser.Model
    | ExplorerModel Explorer.Model
    | DatabaseModel Database.Model
    | ConnManagerModel ConnManager.Model
    | BounceManagerModel BounceManager.Model
    | FinanceModel Finance.Model
    | MusicModel Hebamp.Model
    | CtrlPanelModel CtrlPanel.Model
    | ServersGearsModel ServersGears.Model
    | LocationPickerModel LocationPicker.Model
    | LanViewerModel LanViewer.Model


type Contexts
    = ContextualApp
    | ContextlessApp


type alias WindowID =
    String


contexts : App -> Contexts
contexts app =
    case app of
        LogViewerApp ->
            ContextualApp

        TaskManagerApp ->
            ContextualApp

        BrowserApp ->
            ContextlessApp

        ExplorerApp ->
            ContextualApp

        DatabaseApp ->
            ContextlessApp

        ConnManagerApp ->
            ContextlessApp

        BounceManagerApp ->
            ContextlessApp

        FinanceApp ->
            ContextlessApp

        MusicApp ->
            ContextlessApp

        CtrlPanelApp ->
            ContextlessApp

        ServersGearsApp ->
            ContextlessApp

        LocationPickerApp ->
            ContextlessApp

        LanViewerApp ->
            ContextualApp


name : App -> String
name app =
    case app of
        LogViewerApp ->
            LogViewer.name

        TaskManagerApp ->
            TaskManager.name

        BrowserApp ->
            Browser.name

        ExplorerApp ->
            Explorer.name

        DatabaseApp ->
            Database.name

        ConnManagerApp ->
            ConnManager.name

        BounceManagerApp ->
            BounceManager.name

        FinanceApp ->
            Finance.name

        MusicApp ->
            Hebamp.name

        CtrlPanelApp ->
            CtrlPanel.name

        ServersGearsApp ->
            ServersGears.name

        LocationPickerApp ->
            LocationPicker.name

        LanViewerApp ->
            LanViewer.name


icon : App -> String
icon app =
    case app of
        LogViewerApp ->
            LogViewer.icon

        TaskManagerApp ->
            TaskManager.icon

        BrowserApp ->
            Browser.icon

        ExplorerApp ->
            Explorer.icon

        DatabaseApp ->
            Database.icon

        ConnManagerApp ->
            ConnManager.icon

        BounceManagerApp ->
            BounceManager.icon

        FinanceApp ->
            Finance.icon

        MusicApp ->
            Hebamp.icon

        CtrlPanelApp ->
            CtrlPanel.icon

        ServersGearsApp ->
            ServersGears.icon

        LocationPickerApp ->
            LocationPicker.icon

        LanViewerApp ->
            LanViewer.icon


title : AppModel -> String
title model =
    case model of
        LogViewerModel model ->
            LogViewer.title model

        TaskManagerModel model ->
            TaskManager.title model

        BrowserModel model ->
            Browser.title model

        ExplorerModel model ->
            Explorer.title model

        DatabaseModel model ->
            Database.title model

        ConnManagerModel model ->
            ConnManager.title model

        BounceManagerModel model ->
            BounceManager.title model

        FinanceModel model ->
            Finance.title model

        MusicModel model ->
            Hebamp.title model

        CtrlPanelModel model ->
            CtrlPanel.title model

        ServersGearsModel model ->
            ServersGears.title model

        LocationPickerModel model ->
            LocationPicker.title model

        LanViewerModel model ->
            LanViewer.title model


model : Game.Data -> WindowID -> App -> ( AppModel, Cmd Msg, Dispatch )
model data id app =
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
                    BrowserModel Browser.initialModel
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
                    MusicModel <| Hebamp.initialModel id
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
                    LocationPicker.initialModel id

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


isDecorated : App -> Bool
isDecorated app =
    case app of
        MusicApp ->
            False

        _ ->
            True
