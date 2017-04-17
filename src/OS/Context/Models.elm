module OS.Context.Models exposing (..)

import OS.WindowManager.ContextHandler.Models as ContextHandler


type Context
    = ContextEmpty


type alias Model =
    ContextHandler.Model Context


initialContext : Model
initialContext =
    ContextHandler.initialModel
