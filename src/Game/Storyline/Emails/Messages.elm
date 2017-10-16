module Game.Storyline.Emails.Messages exposing (Msg(..))

import Game.Storyline.Emails.Models exposing (..)
import Events.Account.Story.NewEmail as StoryNewEmail


type Msg
    = Changed Model
    | HandleNewEmail StoryNewEmail.Data
