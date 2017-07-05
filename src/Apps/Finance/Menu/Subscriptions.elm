module Apps.Finance.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.Finance.Menu.Models exposing (Model)
import Apps.Finance.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
