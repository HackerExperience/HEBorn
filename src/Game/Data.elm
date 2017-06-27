module Game.Data exposing (Data, toContext)

import Dict
import Game.Models exposing (..)
import Game.Servers.Models as Servers


type alias Data =
    { game : Model
    , id : Servers.ID
    , server : Servers.Server
    }


toContext : Model -> Maybe Data
toContext model =
    -- FIXME: make this work with the new networking code
    case Dict.get "localhost" model.servers of
        Just server ->
            Just
                { game = model
                , id = "localhost"
                , server = server
                }

        Nothing ->
            Nothing
