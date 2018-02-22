module Events.Account.Handler exposing (events)

import Events.Shared exposing (Router)
import Events.Account.Handlers.ServerPasswordAcquired as ServerPasswordAcquired
import Events.Account.Handlers.StoryStepProceeded as StoryStepProceeded
import Events.Account.Handlers.StoryEmailSent as StoryEmailSent
import Events.Account.Handlers.StoryEmailReplyUnlocked as StoryEmailReplyUnlocked
import Events.Account.Handlers.StoryEmailReplySent as StoryEmailReplySent
import Events.Account.Handlers.BankAccountUpdated as BankAccountUpdated
import Events.Account.Handlers.BankAccountClosed as BankAccountClosed
import Events.Account.Handlers.DbAccountUpdated as DbAccountUpdated
import Events.Account.Handlers.DbAccountRemoved as DbAccountRemoved
import Events.Account.Handlers.TutorialFinished as TutorialFinished
import Events.Account.Handlers.BounceCreated as BounceCreated
import Events.Account.Handlers.BounceUpdated as BounceUpdated
import Events.Account.Handlers.BounceRemoved as BounceRemoved
import Events.Account.Handlers.VirusCollected as VirusCollected
import Events.Account.Config exposing (..)


events : Config msg -> Router msg
events config name value =
    case name of
        "server_password_acquired" ->
            ServerPasswordAcquired.handler config.onServerPasswordAcquired value

        "story_step_proceeded" ->
            StoryStepProceeded.handler config.onStoryStepProceeded value

        "story_email_sent" ->
            StoryEmailSent.handler config.onStoryEmailSent value

        "story_reply_sent" ->
            StoryEmailReplySent.handler config.onStoryEmailReplySent value

        "story_email_reply_unlocked" ->
            StoryEmailReplyUnlocked.handler config.onStoryEmailReplyUnlocked value

        "bank_account_updated" ->
            BankAccountUpdated.handler config.onBankAccountUpdated value

        "bank_account_closed" ->
            BankAccountClosed.handler config.onBankAccountClosed value

        "db_account_updated" ->
            DbAccountUpdated.handler config.onDbAccountUpdated value

        "db_account_removed" ->
            DbAccountRemoved.handler config.onDbAccountRemoved value

        "tutorial_finished" ->
            TutorialFinished.handler config.onTutorialFinished value

        "bounce_created" ->
            BounceCreated.handler config.onBounceCreated value

        "bounce_updated" ->
            BounceUpdated.handler config.onBounceUpdated value

        "bounce_removed" ->
            BounceRemoved.handler config.onBounceRemoved value

        "virus_collected" ->
            VirusCollected.handler config.onVirusCollected value

        _ ->
            Err ""
