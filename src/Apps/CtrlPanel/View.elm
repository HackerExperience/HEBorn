module Apps.CtrlPanel.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import Apps.CtrlPanel.Messages exposing (Msg(..))
import Apps.CtrlPanel.Models exposing (..)
import Apps.CtrlPanel.Resources exposing (Classes(..), prefix)
import Apps.CtrlPanel.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    div [ menuForDummy ] [ menuView model ]
