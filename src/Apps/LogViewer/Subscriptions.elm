module Apps.LogViewer.Subscriptions exposing (..)

import Apps.LogViewer.Models exposing (Model)
import Apps.LogViewer.Messages exposing (Msg(..))
import Apps.LogViewer.Menu.Subscriptions as Menu


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
