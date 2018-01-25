module Apps.BounceManager.Messages exposing (Msg(..))

import Apps.BounceManager.Models exposing (MainTab)
import Game.Meta.Types.Network as Network


type Msg
    = GoTab MainTab
    | UpdateEditing String
    | ToggleNameEdit
    | ApplyNameChangings
    | SelectServer Network.NIP
    | SelectSlot Int
    | SelectEntry Int
    | ClearSelection
    | ServerAdd Network.NIP Int
    | ServerRemove Network.NIP
