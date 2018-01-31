module Game.Subscriptions exposing (subscriptions)

import Game.Models exposing (..)
import Game.Messages exposing (..)
import Game.Meta.Messages as Meta
import Game.Meta.Subscriptions as Meta


subscriptions : Model -> Sub Msg
subscriptions model =
    model
        |> getMeta
        |> Meta.subscriptions
        |> Sub.map MetaMsg
