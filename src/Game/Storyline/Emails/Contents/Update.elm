module Game.Storyline.Emails.Contents.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Game.Storyline.Emails.Contents.Messages exposing (..)


type alias UpdateResponse =
    ( Cmd Msg, Dispatch )


update : Game.Data -> Msg -> UpdateResponse
update game msg =
    case msg of
        OpenAddr ip ->
            onOpenAddr ip


onOpenAddr : String -> UpdateResponse
onOpenAddr _ =
    ( Cmd.none, Dispatch.none )
