module Game.Storyline.Emails.Messages exposing (Msg(..))

import Game.Storyline.Emails.Models exposing (..)
import Events.Account.Story.NewEmail as StoryNewEmail
import Events.Account.Story.ReplyUnlocked as StoryReplyUnlocked


type Msg
    = Changed Model
    | HandleNewEmail StoryNewEmail.Data
    | HandleReplyUnlocked StoryReplyUnlocked.Data
