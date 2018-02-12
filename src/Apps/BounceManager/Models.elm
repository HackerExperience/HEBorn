module Apps.BounceManager.Models exposing (..)

import Game.Account.Bounces.Models as Bounces
import Game.Account.Bounces.Shared as Bounces
import Game.Meta.Types.Network exposing (NIP)
import Game.Meta.Types.Apps.Desktop exposing (Reference)


type MainTab
    = TabManage
    | TabBuild ( Maybe Bounces.ID, Bounces.Bounce )


type Selection
    = SelectingSlot Int
    | SelectingEntry NIP
    | SelectingServer NIP


type ModalAction
    = ForReset ( Maybe Bounces.ID, Bounces.Bounce )
    | ForEditWithoutSave Bounces.ID
    | ForSave ( Maybe Bounces.ID, Bounces.Bounce )
    | ForError Error
    | ForSaveSucessful


type Params
    = WithBounce Bounces.ID


type Error
    = CreateError Bounces.CreateError
    | UpdateError Bounces.UpdateError
    | RemoveError Bounces.RemoveError


type alias Model =
    { selected : MainTab
    , selection : Maybe Selection
    , anyChange : Bool
    , selectedBounce : Maybe ( Maybe Bounces.ID, Bounces.Bounce )
    , renaming : Bool
    , path : List NIP
    , bounceNameBuffer : Maybe String
    , modal : Maybe ModalAction
    , expanded : List Bounces.ID
    , me : Reference
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


initialModel : Reference -> Model
initialModel me =
    { selected = TabManage
    , selection = Nothing
    , anyChange = False
    , selectedBounce = Nothing
    , renaming = False
    , path = []
    , bounceNameBuffer = Nothing
    , modal = Nothing
    , expanded = []
    , me = me
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


getCurrentBouncePath : MainTab -> List NIP
getCurrentBouncePath tab =
    case tab of
        TabBuild ( id, bounce ) ->
            bounce.path

        _ ->
            []


reset : MainTab -> Model -> Model
reset selected model =
    let
        path_ =
            getCurrentBouncePath selected
    in
        { model
            | selected = selected
            , selection = Nothing
            , bounceNameBuffer = Nothing
            , path = path_
            , anyChange = False
            , renaming = False
        }


emptyBounceBuildTab : MainTab
emptyBounceBuildTab =
    TabBuild ( Nothing, Bounces.emptyBounce )
