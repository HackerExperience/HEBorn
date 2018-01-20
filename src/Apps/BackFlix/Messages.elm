module Apps.BackFlix.Messages exposing (Msg(..))

import Apps.BackFlix.Models exposing (MainTab)


type Msg
    = UpdateTextFilter String
    | GoTab MainTab
