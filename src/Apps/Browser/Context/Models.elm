module Apps.Browser.Context.Models exposing (..)

import OS.WindowManager.ContextHandler.Models as ContextHandler


type Context
    = ContextNav
    | ContextContent


type alias Model =
    ContextHandler.Model Context


initialContext : Model
initialContext =
    ContextHandler.initialModel
