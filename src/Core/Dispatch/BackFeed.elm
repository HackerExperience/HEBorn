module Core.Dispatch.BackFeed exposing (..)

import Time exposing (Time)
import Game.BackFeed.Models as Models
import Events.BackFeed.Created as LogCreated
import Game.Web.Models as Web
import Game.Web.Types as Web


type Dispatch
    = Create Models.BackLog
