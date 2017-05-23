module Apps.Models
    exposing
        ( AppModel(..)
        , App(..)
        , Contexts(..)
        , contexts
        , name
        , title
        , icon
        , model
        )

import Apps.LogViewer.Models as LogViewer


type App
    = LogViewerApp


type AppModel
    = LogViewerModel LogViewer.Model


type Contexts
    = ContextualApp
    | ContextlessApp


contexts : App -> Contexts
contexts app =
    case app of
        LogViewerApp ->
            ContextualApp


name : App -> String
name app =
    case app of
        LogViewerApp ->
            LogViewer.name


icon : App -> String
icon app =
    case app of
        LogViewerApp ->
            LogViewer.icon


title : AppModel -> String
title model =
    case model of
        LogViewerModel model ->
            LogViewer.title model


model : App -> AppModel
model app =
    case app of
        LogViewerApp ->
            LogViewerModel LogViewer.initialModel
