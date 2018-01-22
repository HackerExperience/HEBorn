module Apps.DBAdmin.Config exposing (..)

import Game.Account.Database.Models as Database
import Apps.DBAdmin.Messages exposing (..)
import Apps.DBAdmin.Menu.Config as Menu


type alias Config msg =
    { toMsg : Msg -> msg
    , database : Database.Model
    , batchMsg : List msg -> msg
    }


menuConfig : Config msg -> Menu.Config msg
menuConfig config =
    { toMsg = MenuMsg >> config.toMsg
    , database = config.database
    , batchMsg = config.batchMsg
    }
