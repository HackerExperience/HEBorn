module Game.Storyline.Requests exposing (Response(..), receive)

import Game.Storyline.Messages exposing (RequestMsg(..))
import Game.Storyline.Requests.Reply as Reply
import Game.Storyline.Shared exposing (Reply, ContactId)


type Response
    = Reply ( ContactId, Reply ) Reply.Response


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        ReplyRequest src ( code, data ) ->
            Reply.receive code data
                |> Maybe.map (Reply src)
