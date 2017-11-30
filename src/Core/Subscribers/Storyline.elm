module Core.Subscribers.Storyline exposing (dispatch)

import Core.Dispatch.Storyline exposing (..)
import Core.Subscribers.Helpers exposing (..)
import Core.Messages as Core
import Events.Account.Story.NewEmail as StoryNewEmail
import Game.Messages as Game
import Game.Notifications.Models as Notifications
import Game.Notifications.Messages as Notifications
import Game.Storyline.Messages as Storyline
import Game.Storyline.Emails.Messages as Emails
import Game.Storyline.Missions.Messages as Missions


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        Toggle ->
            [ storyline Storyline.HandleToggle ]

        Emails dispatch ->
            fromEmails dispatch

        Missions dispatch ->
            fromMissions dispatch



-- internals


fromEmails : Emails -> Subscribers
fromEmails dispatch =
    case dispatch of
        ReplyEmail a ->
            [ emails <| Emails.HandleReply a ]

        ReceivedEmail a ->
            [ emails <| Emails.HandleNewEmail a
            , accountNotif <|
                StoryNewEmail.notify Notifications.NewEmail
                    Notifications.HandleInsert
                    a
            ]

        UnlockedEmail a ->
            [ emails <| Emails.HandleReplyUnlocked a ]


fromMissions : Missions -> Subscribers
fromMissions dispatch =
    case dispatch of
        ActionDone a ->
            [ missions <| Missions.HandleActionDone a ]

        ProceededMission a ->
            [ missions <| Missions.HandleStepProceeded a ]

        _ ->
            []
