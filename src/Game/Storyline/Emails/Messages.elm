module Game.Storyline.Emails.Messages exposing (Msg(..), RequestMsg(..))

import Time exposing (Time)
import Requests.Types exposing (ResponseType)
import Game.Storyline.Emails.Models exposing (..)
import Game.Storyline.Emails.Contents exposing (Content)
import Events.Account.Handlers.StoryEmailSent as StoryEmailSent
import Events.Account.Handlers.StoryEmailReplyUnlocked as StoryEmailReplyUnlocked
import Events.Account.Handlers.StoryEmailReplySent as StoryEmailReplySent


type Msg
    = Changed Model
    | HandleReply String Content
    | HandleNewEmail StoryEmailSent.Data
    | HandleReplyUnlocked StoryEmailReplyUnlocked.Data
    | HandleReplySent StoryEmailReplySent.Data
    | Request RequestMsg


type RequestMsg
    = ReplyRequest ( String, Content ) ResponseType
