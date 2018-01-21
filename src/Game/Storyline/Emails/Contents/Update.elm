module Game.Storyline.Emails.Contents.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Storyline.Emails.Contents.Config exposing (..)
import Game.Storyline.Emails.Contents.Messages exposing (..)


type alias UpdateResponse =
    ( Cmd Msg, Dispatch )


update : Config -> Msg -> UpdateResponse
update config msg =
    case msg of
        OpenAddr ip ->
            onOpenAddr ip


onOpenAddr : String -> UpdateResponse
onOpenAddr _ =
    ( Cmd.none, Dispatch.none )
