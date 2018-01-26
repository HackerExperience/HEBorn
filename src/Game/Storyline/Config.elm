module Game.Storyline.Config exposing (..)

import Core.Flags as Core
import Game.Storyline.Emails.Config as Emails
import Game.Storyline.Missions.Config as Missions
import Game.Storyline.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , flags : Core.Flags
    , accountId : String
    }


emailsConfig : Config msg -> Emails.Config msg
emailsConfig config =
    { toMsg = EmailsMsg >> config.toMsg
    , flags = config.flags
    , accountId = config.accountId
    }


missionsConfig : Config msg -> Missions.Config msg
missionsConfig config =
    { toMsg = MissionsMsg >> config.toMsg
    }
