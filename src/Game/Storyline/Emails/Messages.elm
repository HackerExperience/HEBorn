module Game.Storyline.Emails.Messages exposing (Msg(..))

import Game.Storyline.Emails.Models exposing (Model, ReceiveData)


type Msg
    = Changed Model
    | Receive ReceiveData
