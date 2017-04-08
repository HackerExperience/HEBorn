module Apps.Explorer.Update exposing (update)


import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg)
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages exposing (Msg(..))


update : Msg -> Model -> GameModel -> (Model, Cmd Msg, List GameMsg)
update msg model game =
    case msg of
        Event event ->
            (model, Cmd.none, [])

        Request _ ->
            (model, Cmd.none, [])

        Response request data ->
            (model, Cmd.none, [])
