module Apps.LogViewer.Config exposing (..)

import Game.Servers.Logs.Models as Logs
import Apps.LogViewer.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , logs : Logs.Model
    , batchMsg : List msg -> msg
    , onUpdateLog : Logs.ID -> String -> msg
    , onEncryptLog : Logs.ID -> msg
    , onHideLog : Logs.ID -> msg
    , onDeleteLog : Logs.ID -> msg
    }
