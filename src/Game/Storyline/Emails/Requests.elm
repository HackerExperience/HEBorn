module Game.Storyline.Emails.Requests exposing (Response(..), receive)

import Game.Storyline.Emails.Messages exposing (RequestMsg(..))
import Game.Storyline.Emails.Requests.Reply as Reply


type Response
    = Reply Reply.Response


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        ReplyRequest ( code, data ) ->
            Reply.receive code data
                |> Maybe.map Reply
