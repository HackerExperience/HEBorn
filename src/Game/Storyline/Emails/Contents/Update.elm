module Game.Storyline.Emails.Contents.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Storyline.Emails.Contents.Config exposing (..)
import Game.Storyline.Emails.Contents.Messages exposing (..)


update : Config -> Msg -> React Msg
update config msg =
    case msg of
        OpenAddr ip ->
            onOpenAddr ip


onOpenAddr : String -> React Msg
onOpenAddr _ =
    React.none
