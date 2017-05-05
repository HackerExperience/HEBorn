module Apps.LogViewer.Context.Models exposing (..)

import OS.WindowManager.ContextHandler.Models as ContextHandler


type Context
    = ContextMain


type alias Model =
    ContextHandler.Model Context


initialContext : Model
initialContext =
    ContextHandler.initialModel
