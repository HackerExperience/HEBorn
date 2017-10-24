module Events.Account exposing (Event(..), events)

import Events.Types exposing (Router)
import Events.Account.PasswordAcquired as PasswordAcquired
import Events.Account.Story.StepProceeded as StoryStepProceeded
import Events.Account.Story.NewEmail as StoryNewEmail
import Events.Account.Story.ReplyUnlocked as StoryReplyUnlocked


type Event
    = PasswordAcquired PasswordAcquired.Data
    | StoryStepProceeded StoryStepProceeded.Data
    | StoryNewEmail StoryNewEmail.Data
    | StoryReplyUnlocked StoryReplyUnlocked.Data


events : Router Event
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
