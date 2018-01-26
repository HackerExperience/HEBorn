module Game.Storyline.Emails.Requests exposing (Response(..), receive)

import Game.Storyline.Emails.Messages exposing (RequestMsg(..))
import Game.Storyline.Emails.Requests.Reply as Reply
import Game.Storyline.Emails.Contents exposing (Content)


type Response
    = Reply ( String, Content ) Reply.Response


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        ReplyRequest src ( code, data ) ->
            Reply.receive code data
                |> Maybe.map (Reply src)
