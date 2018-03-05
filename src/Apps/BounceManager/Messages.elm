module Apps.BounceManager.Messages exposing (Msg(..))

import Game.Account.Bounces.Models as Bounces
import Game.Account.Bounces.Shared as Bounces
import Game.Meta.Types.Network exposing (NIP)
import Apps.BounceManager.Models exposing (..)
import Apps.BounceManager.Shared exposing (..)


type Msg
    = GoTab MainTab
    | UpdateEditing String
    | ToggleNameEdit
    | ApplyNameChangings
    | SelectSlot Int
    | SelectEntry NIP
    | SelectServer NIP
    | AddNode NIP Int
    | RemoveNode NIP
    | MoveNode NIP Int
    | ClearSelection
    | SetModal (Maybe ModalAction)
    | Save ( Maybe Bounces.ID, Bounces.Bounce )
    | Edit Bounces.ID
    | Reset ( Maybe Bounces.ID, Bounces.Bounce )
    | Delete (Maybe Bounces.ID)
    | ToggleExpand String
    | LaunchApp Params
    | CreateRequest (Maybe Bounces.CreateError)
    | UpdateRequest (Maybe Bounces.UpdateError)
    | RemoveRequest (Maybe Bounces.RemoveError)
