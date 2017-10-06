module Game.Storyline.Emails.Messages exposing (Msg(..))

import Game.Storyline.Emails.Models exposing (..)


type Msg
    = Changed Model
    | NewEmail ID ( Float, Message ) Responses
