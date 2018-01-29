module Apps.DBAdmin.Config exposing (..)

import Game.Account.Database.Models as Database
import Apps.DBAdmin.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , database : Database.Model
    , batchMsg : List msg -> msg
    }
