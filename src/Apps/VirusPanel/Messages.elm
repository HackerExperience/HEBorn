module Apps.VirusPanel.Messages exposing (Msg(..))

import Game.Meta.Types.Network exposing (NIP)
import Game.Account.Database.Shared exposing (..)
import Apps.VirusPanel.Models exposing (..)


type Msg
    = GoTab MainTab
    | SetModal (Maybe ModalAction)
    | ChangeActiveVirus NIP
    | SetActiveVirus (Maybe String)
    | Select (Maybe CollectBehavior)
    | Collect
    | Check NIP
    | CheckAll
    | HandleCollected (Result CollectWithBankError ())
