module Game.Servers.Tunnels.Update exposing (update)

{-| Documentação pendente pois este domínio está incompleto e provavelmente
errado.
-}

import Utils.React as React exposing (React)
import Game.Servers.Tunnels.Config exposing (..)
import Game.Servers.Tunnels.Messages exposing (..)
import Game.Servers.Tunnels.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    ( model, React.none )
