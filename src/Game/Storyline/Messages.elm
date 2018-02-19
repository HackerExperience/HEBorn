module Game.Storyline.Messages exposing (Msg(..))

import Game.Storyline.Models exposing (..)
import Game.Storyline.Shared exposing (..)


type Msg
    = HandleReply ContactID Reply
    | HandleNewEmail StoryEmailSent.Data
    | HandleReplyUnlocked StoryEmailReplyUnlocked.Data
    | HandleReplySent StoryEmailReplySent.Data
    | HandleActionDone Action
    | HandleStepProceeded StoryStepProceeded.Data
    | Request RequestMsg


type RequestMsg
    = ReplyRequest ( ContactID, Reply ) ResponseType
