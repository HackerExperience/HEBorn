module Apps.ConnManager.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import Apps.ConnManager.Messages exposing (Msg(..))
import Apps.ConnManager.Models exposing (..)
import Apps.ConnManager.Style exposing (Classes(..))
import Apps.ConnManager.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "connmngr"


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    div [ class [ Dummy ] ]
        [ menuView model ]
