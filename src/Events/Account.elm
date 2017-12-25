module Events.Account exposing (events)

import Events.Types exposing (Router)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Account as Account
import Core.Dispatch.Storyline as Storyline
import Events.Account.PasswordAcquired as PasswordAcquired
import Events.Account.Story.StepProceeded as StoryStepProceeded
import Events.Account.Story.NewEmail as StoryNewEmail
import Events.Account.Story.ReplyUnlocked as StoryReplyUnlocked
import Events.Account.Database.AccountUpdated as AccountUpdated
import Events.Account.Database.AccountRemoved as AccountRemoved
import Events.Account.Finances.BankAccountClosed as BankAccountClosed
import Events.Account.Finances.BankAccountUpdated as BankAccountUpdated


events : Router Dispatch
events name json =
    case name of
        "server_password_acquired" ->
            PasswordAcquired.handler onPasswordAcquired json

        "story_step_proceeded" ->
            StoryStepProceeded.handler onStoryStepProceeded json

        "story_email_sent" ->
            StoryNewEmail.handler onStoryNewEmail json

        "story_email_reply_unlocked" ->
            StoryReplyUnlocked.handler onStoryReplyUnlocked json

        "bank_account_closed" ->
            BankAccountClosed.handler onBankAccountClosed json

        "bank_account_updated" ->
            BankAccountUpdated.handler onBankAccountUpdated json

        "db_account_updated" ->
            AccountUpdated.handler onAccountUpdated json

        "db_account_removed" ->
            AccountRemoved.handler onAccountRemoved json

        _ ->
            Err ""



-- internals


onPasswordAcquired : PasswordAcquired.Data -> Dispatch
onPasswordAcquired =
    Account.PasswordAcquired >> Dispatch.account


onStoryStepProceeded : StoryStepProceeded.Data -> Dispatch
onStoryStepProceeded =
    Storyline.ProceededMission >> Dispatch.missions


onStoryNewEmail : StoryNewEmail.Data -> Dispatch
onStoryNewEmail =
    Storyline.ReceivedEmail >> Dispatch.emails


onStoryReplyUnlocked : StoryReplyUnlocked.Data -> Dispatch
onStoryReplyUnlocked =
    Storyline.UnlockedEmail >> Dispatch.emails


onBankAccountClosed : BankAccountClosed.Data -> Dispatch
onBankAccountClosed =
    Account.BankAccountClosed >> Dispatch.finances


onBankAccountUpdated : BankAccountUpdated.Data -> Dispatch
onBankAccountUpdated =
    Account.BankAccountUpdated >> Dispatch.finances


onAccountUpdated : AccountUpdated.Data -> Dispatch
onAccountUpdated =
    Account.DatabaseAccountUpdated >> Dispatch.database


onAccountRemoved : AccountRemoved.Data -> Dispatch
onAccountRemoved =
    Account.DatabaseAccountRemoved >> Dispatch.database
