module Apps.Browser.Pages.Webserver.View exposing (view)

import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers
import Game.Data as Game
import Game.Servers.Shared as Servers
import Game.Network.Types exposing (NIP)
import Apps.Apps as Apps
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.Webserver.Messages exposing (Msg(..))
import Apps.Browser.Pages.Webserver.Models exposing (Model)
import Apps.Browser.Widgets.HackingToolkit.View as HackingToolkit exposing (hackingToolkit)
import Apps.Browser.Widgets.HackingPanel.View as HackingPanel exposing (hackingPanel)
import Apps.Browser.Widgets.PublicFiles.View as PublicFiles exposing (publicFiles)


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
    { source = source
    , onCommonAction = GlobalMsg
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
        -- this is cheating:
        cid =
            Servers.EndpointCId model.toolkit.target

        endpointMember =
            List.member cid (Game.getEndpoints data)
    in
        if (model.showingPanel && endpointMember) then
            hackingPanel hackingPanelConfig model.toolkit.target
        else
            viewPre data (not endpointMember) model


viewPre : Game.Data -> Bool -> Model -> Html Msg
viewPre data showPassword model =
    div [ class [ AutoHeight ] ]
        [ (if model.custom == "" then
            "No Webserver running"
           else
            model.custom
          )
            |> text
            |> List.singleton
            |> div [ class [ DummyTitle ] ]
        , publicFiles
            (publicFilesConfig model.toolkit.target)
            model.publicFiles
        , hackingToolkit
            (hackingToolkitConfig showPassword)
            model.toolkit
        ]
