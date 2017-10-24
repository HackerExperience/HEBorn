module Game.Storyline.Emails.Messages exposing (Msg(..), RequestMsg(..))

import Requests.Types exposing (ResponseType)
import Game.Storyline.Emails.Models exposing (..)
import Game.Storyline.Emails.Contents exposing (Content)
import Events.Account.Story.NewEmail as StoryNewEmail
import Events.Account.Story.ReplyUnlocked as StoryReplyUnlocked


type Msg
    = Changed Model
    | Reply Content
    | HandleNewEmail StoryNewEmail.Data
    | HandleReplyUnlocked StoryReplyUnlocked.Data
    | Request RequestMsg


type RequestMsg
    = ReplyRequest ResponseType
