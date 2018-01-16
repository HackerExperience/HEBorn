module Apps.Popup.Messages exposing (Msg(..))

import Apps.Popup.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
    | Activation
    | ContinueOnCampaign
