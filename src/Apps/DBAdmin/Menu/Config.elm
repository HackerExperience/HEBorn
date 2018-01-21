module Apps.DBAdmin.Menu.Config exposing (..)

import Game.Account.Database.Models as Database
import Apps.DBAdmin.Menu.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , database : Database.Model
    }
