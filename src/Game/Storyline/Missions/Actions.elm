module Game.Storyline.Missions.Actions exposing (Action(..), fromStep)

import Apps.Apps exposing (App(..))


type alias ID =
    String


type Action
    = RunFile ID
    | RunApp App


fromStep : ID -> List Action
fromStep id =
    case id of
        "001" ->
            [ RunApp ExplorerApp, RunFile "003" ]

        _ ->
            []
