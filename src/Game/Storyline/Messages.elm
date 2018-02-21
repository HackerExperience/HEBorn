module Game.Storyline.Messages exposing (..)

import Requests.Types exposing (ResponseType)
import Events.Account.Handlers.StoryEmailSent as StoryEmailSent
import Events.Account.Handlers.StoryEmailReplyUnlocked as StoryEmailReplyUnlocked
import Events.Account.Handlers.StoryEmailReplySent as StoryEmailReplySent
import Events.Account.Handlers.StoryStepProceeded as StoryStepProceeded
import Game.Storyline.Shared exposing (ContactId, Reply)
import Game.Storyline.StepActions.Shared exposing (Action)


type Msg
    = HandleReply ContactId Reply
    | HandleNewEmail StoryEmailSent.Data
    | HandleReplyUnlocked StoryEmailReplyUnlocked.Data
    | HandleReplySent StoryEmailReplySent.Data
    | HandleActionDone Action
    | HandleStepProceeded StoryStepProceeded.Data
    | Request RequestMsg


type RequestMsg
    = ReplyRequest ( ContactId, Reply ) ResponseType
