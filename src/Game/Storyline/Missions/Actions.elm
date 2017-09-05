module Game.Storyline.Missions.Actions exposing (Action(..), fromSteps)

import Apps.Apps exposing (App(..))


type alias ID =
    String


type Action
    = RunFile ID
    | RunApp App


fromSteps : ID -> List Action
fromSteps id =
    case id of
        "001" ->
            [ RunApp ExplorerApp ]

        _ ->
            []
