module Events.Account exposing (events)

import Events.Types exposing (Router)
import Core.Dispatch.Websocket exposing (..)
import Events.Account.PasswordAcquired as PasswordAcquired
import Events.Account.Story.StepProceeded as StoryStepProceeded
import Events.Account.Story.NewEmail as StoryNewEmail
import Events.Account.Story.ReplyUnlocked as StoryReplyUnlocked


events : Router AccountEvent
events name json =
    case name of
        "server_password_acquired" ->
            PasswordAcquired.handler PasswordAcquired json

        "story_step_proceeded" ->
            StoryStepProceeded.handler StoryStepProceeded json

        "story_email_sent" ->
            StoryNewEmail.handler StoryNewEmail json

        "story_email_reply_unlocked" ->
            StoryReplyUnlocked.handler StoryReplyUnlocked json

        _ ->
            Err ""
