module Apps.Browser.Pages.NoWebserver.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers
import Game.Data as Game
import Game.Network.Types exposing (NIP)
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.CommonActions exposing (CommonActions(Crack))
import Apps.Browser.Pages.NoWebserver.Messages exposing (Msg(..))
import Apps.Browser.Pages.NoWebserver.Models exposing (Model)
import Apps.Browser.Widgets.HackingToolkit.View as HackingToolkit exposing (hackingToolkit)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


hackingToolkitConfig : HackingToolkit.Config Msg
hackingToolkitConfig =
    { onInput = UpdatePasswordField
    , onCommonAction = GlobalMsg
    }


view : Game.Data -> Model -> Html Msg
view data model =
    div [ class [ AutoHeight ] ]
        [ div [ class [ LoginPageHeader ] ] [ text "No web server running" ]
        , hackingToolkit hackingToolkitConfig model.toolkit
        ]
