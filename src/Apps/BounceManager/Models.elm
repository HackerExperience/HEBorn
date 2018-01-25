module Apps.BounceManager.Models exposing (..)

import Game.Account.Bounces.Models as Bounces


type MainTab
    = TabManage
    | TabBuild


type Selection
    = SelectingSlot
    | SelectingEntry


type alias Model =
    { selected : MainTab
    , selection : Maybe Selection
    , anyChange : Bool
    , activeBounce : Maybe Bounces.Bounce
    }


name : String
name =
    "Bounce Manager"


title : Model -> String
title model =
    "Bounce Manager"


icon : String
icon =
    "bouncemngr"


initialModel : Model
initialModel =
    { selected = TabManage
    , selection = Nothing
    , anyChange = False
    , activeBounce = Nothing
    }


tabToString : MainTab -> String
tabToString tab =
    case tab of
        TabManage ->
            "Manage"

        TabBuild ->
            "Build"


setAnyChanges : Bool -> Model -> Model
setAnyChanges anyChange model =
    { model | anyChange = anyChange }


getActiveBounce : Model -> Maybe Bounces.Bounce
getActiveBounce =
    .activeBounce
