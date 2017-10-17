module Apps.Browser.Pages.DownloadCenter.View exposing (view)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers
import Game.Data as Game
import Game.Network.Types exposing (NIP)
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.DownloadCenter.Messages exposing (..)
import Apps.Browser.Pages.DownloadCenter.Models exposing (..)
import Apps.Browser.Widgets.HackingToolkit.View as HackingToolkit exposing (hackingToolkit)
import Apps.Browser.Widgets.HackingPanel.View as HackingPanel exposing (hackingPanel)
import Apps.Browser.Widgets.PublicFiles.View as PublicFiles exposing (publicFiles)
import Game.Network.Types exposing (NIP)
import Apps.Apps as Apps


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


hackingToolkitConfig : Bool -> HackingToolkit.Config Msg
hackingToolkitConfig showPassword =
    { onInput = UpdatePasswordField
    , onCommonAction = GlobalMsg
    , onEnterPanel = SetShowingPanel True
    , showPassword = showPassword
    }


publicFilesConfig : NIP -> PublicFiles.Config Msg
publicFilesConfig source =
    { reqDownload = StartDownload source
    }


hackingPanelConfig : HackingPanel.Config Msg
hackingPanelConfig =
    { onCommonAction = GlobalMsg
    , onSetShowingPanel = SetShowingPanel
    , apps =
        [ Apps.TaskManagerApp
        , Apps.ConnManagerApp
        , Apps.LogViewerApp
        , Apps.ExplorerApp
        ]
    , allowAnyMap = True
    , allowSelectEndpoint = True
    }


view : Game.Data -> Model -> Html Msg
view data model =
    let
        endpointMember =
            List.member
                model.toolkit.target
                (Game.getEndpoints data)
    in
        if (model.showingPanel && endpointMember) then
            viewPos model.toolkit.target
        else
            viewPre data (not endpointMember) model


viewPre : Game.Data -> Bool -> Model -> Html Msg
viewPre data showPassword model =
    div [ class [ AutoHeight ] ]
        [ div [ class [ DummyTitle ] ]
            [ text <| "Welcome to " ++ model.title ++ "!" ]
        , publicFiles
            (publicFilesConfig model.toolkit.target)
            model.publicFiles
        , hackingToolkit
            (hackingToolkitConfig showPassword)
            model.toolkit
        ]


viewPos : NIP -> Html Msg
viewPos nip =
    hackingPanel hackingPanelConfig nip
