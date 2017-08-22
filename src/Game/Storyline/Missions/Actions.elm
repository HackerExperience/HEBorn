module Game.Storyline.Missions.Actions exposing (Action(..))

import Apps.Apps exposing (App(..))


type alias ID =
    String


type Action
    = RunFile ID
    | RunApp App
