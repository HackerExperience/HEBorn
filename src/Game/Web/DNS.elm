module Game.Web.DNS exposing (..)

import Game.Web.Types exposing (..)
import Game.Web.Models exposing (..)


type Response
    = Okay Site
    | NotFounded Url
    | ConnectionError Url
