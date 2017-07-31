module Apps.LanViewer.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import Apps.LanViewer.Messages exposing (Msg(..))
import Apps.LanViewer.Models exposing (..)
import Apps.LanViewer.Resources exposing (Classes(..), prefix)
import Apps.LanViewer.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    div [ menuForDummy ] [ menuView model ]
