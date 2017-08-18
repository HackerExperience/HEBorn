module Game.Storyline.Missions.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Models as Game
import Game.Storyline.Missions.Models exposing (..)
import Game.Storyline.Missions.Messages exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        ActionDone action ->
            List.map
                (\mission ->
                    { mission
                        | now =
                            List.filter ((/=) action) mission.now
                    }
                )
                model
                |> Update.fromModel
