module Apps.BounceManager.Messages exposing (Msg(..))

import Apps.BounceManager.Models exposing (..)
import Game.Meta.Types.Context exposing (Context)
import Game.Account.Bounces.Models as Bounces
import Game.Account.Bounces.Shared as Bounces
import Game.Meta.Types.Network as Network


type Msg
    = GoTab MainTab
    | UpdateEditing String
    | ToggleNameEdit
    | ApplyNameChangings
    | SelectSlot Int
    | SelectEntry Network.NIP
    | SelectServer Network.NIP
    | AddNode Network.NIP Int
    | RemoveNode Network.NIP
    | MoveNode Network.NIP Int
    | ClearSelection
    | SetModal (Maybe ModalAction)
    | Save ( Maybe Bounces.ID, Bounces.Bounce )
    | Edit Bounces.ID
    | Reset ( Maybe Bounces.ID, Bounces.Bounce )
    | Delete (Maybe Bounces.ID)
    | NoAction
    | ToggleExpand String
    | LaunchApp Context Params
    | CreateRequest (Result Error ())
    | UpdateRequest (Result Error ())
    | RemoveRequest (Result Error ())
