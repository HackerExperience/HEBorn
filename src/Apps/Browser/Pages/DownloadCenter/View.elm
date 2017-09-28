module Apps.Browser.Pages.DownloadCenter.View exposing (view)

import Game.Data as Game
import Apps.Browser.Widgets.HackingToolkit.View as HackingToolkit exposing (hackingToolkit)
import Apps.Browser.Pages.DownloadCenter.Messages exposing (..)
import Apps.Browser.Pages.DownloadCenter.Models exposing (..)
import Html exposing (Html, div, text)


hackingToolkitConfig : HackingToolkit.Config Msg
hackingToolkitConfig =
    { onInput = UpdatePasswordField
    , onCommonAction = GlobalMsg
    }


view : Game.Data -> Model -> Html Msg
view game model =
    div []
        [ text "TODO"
        , hackingToolkit hackingToolkitConfig model.toolkit
        ]
