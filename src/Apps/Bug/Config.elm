module Apps.Bug.Config exposing (..)

import Game.Account.Notifications.Shared as AccountNotifications
import Apps.Bug.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , onAccountToast : AccountNotifications.Content -> msg
    , onPoliteCrash : ( String, String ) -> msg
    }
