module Game.Servers.Filesystem.Requests.Move exposing (moveRequest)

import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..), ResponseType)
import Game.Servers.Shared exposing (CId)
import Game.Servers.Filesystem.Shared exposing (..)


{-| Cria um Cmd de request para mover um arquivo.
-}
moveRequest : Path -> Id -> CId -> FlagsSource a -> Cmd ResponseType
moveRequest path id cid =
    Requests.request (Topics.fsMove cid)
        (encoder path id)



-- funções internas


encoder : Path -> Id -> Value
encoder path id =
    let
        -- TODO: enviar uma string simples pode ser melhor
        destination =
            path
                |> List.map Encode.string
                |> Encode.list
    in
        Encode.object
            [ ( "file_id", Encode.string id )
            , ( "destination", destination )
            ]
