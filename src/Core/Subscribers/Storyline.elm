module Core.Subscribers.Storyline exposing (dispatch)

import Core.Dispatch.Storyline exposing (..)
import Core.Subscribers.Helpers exposing (..)
import Core.Messages as Core
import Game.Messages as Game
import Game.Storyline.Messages as Storyline
import Game.Storyline.Emails.Messages as Emails
import Game.Storyline.Missions.Messages as Missions


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        Emails dispatch ->
            fromEmails dispatch

        Missions dispatch ->
            fromMissions dispatch



-- internals


fromEmails : Emails -> Subscribers
fromEmails dispatch =
    case dispatch of
        ReceivedEmail a ->
            [ emails <| Emails.HandleNewEmail a ]

        UnlockedEmail a ->
            [ emails <| Emails.HandleReplyUnlocked a ]


fromMissions : Missions -> Subscribers
fromMissions dispatch =
    case dispatch of
        ProceededMission a ->
            [ missions <| Missions.HandleStepProceeded a ]

        _ ->
            []
