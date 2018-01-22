module Game.Storyline.Emails.Messages exposing (Msg(..), RequestMsg(..))

import Requests.Types exposing (ResponseType)
import Game.Storyline.Emails.Models exposing (..)
import Game.Storyline.Emails.Contents exposing (Content)
import Events.Account.Handlers.StoryEmailSent as StoryEmailSent
import Events.Account.Handlers.StoryEmailReplyUnlocked as StoryEmailReplyUnlocked


type Msg
    = Changed Model
    | HandleReply Content
    | HandleNewEmail StoryEmailSent.Data
    | HandleReplyUnlocked StoryEmailReplyUnlocked.Data
    | Request RequestMsg


type RequestMsg
    = ReplyRequest ResponseType
