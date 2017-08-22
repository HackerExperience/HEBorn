module Apps.Email.Messages exposing (Msg(..))

import Apps.Email.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
    | SelectContact String
