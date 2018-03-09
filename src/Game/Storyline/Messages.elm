module Game.Storyline.Messages exposing (..)

import Events.Account.Handlers.StoryEmailSent as StoryEmailSent
import Events.Account.Handlers.StoryEmailReplyUnlocked as StoryEmailReplyUnlocked
import Events.Account.Handlers.StoryEmailReplySent as StoryEmailReplySent
import Events.Account.Handlers.StoryStepProceeded as StoryStepProceeded
import Game.Storyline.StepActions.Shared exposing (Action)
import Game.Storyline.Requests.Reply as ReplyRequest
import Game.Storyline.Shared exposing (ContactId, Reply)


type Msg
    = HandleReply ContactId Reply
    | HandleNewEmail StoryEmailSent.Data
    | HandleReplyUnlocked StoryEmailReplyUnlocked.Data
    | HandleReplySent StoryEmailReplySent.Data
    | HandleActionDone Action
    | HandleStepProceeded StoryStepProceeded.Data
    | ReplyRequest ReplyRequest.Data
