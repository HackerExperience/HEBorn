module Apps.BounceManager.Models exposing (..)

import Game.Account.Bounces.Models as Bounces
import Game.Account.Bounces.Shared as Bounces
import Game.Meta.Types.Network as Network


type MainTab
    = TabManage
    | TabBuild ( Maybe Bounces.ID, Bounces.Bounce )


type Selection
    = SelectingSlot Int
    | SelectingEntry Int
    | SelectingServer Network.NIP


type alias Model =
    { selected : MainTab
    , selection : Maybe Selection
    , anyChange : Bool
    , selectedBounce : Maybe ( Maybe Bounces.ID, Bounces.Bounce )
    , editing : Bool
    , path : List Network.NIP
    , bounceNameBuffer : Maybe String
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
    , selectedBounce = Nothing
    , editing = False
    , path = []
    , bounceNameBuffer = Nothing
    }


tabToString : MainTab -> String
tabToString tab =
    case tab of
        TabManage ->
            "Manage"

        TabBuild _ ->
            "Build"


setAnyChanges : Bool -> Model -> Model
setAnyChanges anyChange model =
    { model | anyChange = anyChange }


windowInitSize : ( Float, Float )
windowInitSize =
    ( 800, 600 )
