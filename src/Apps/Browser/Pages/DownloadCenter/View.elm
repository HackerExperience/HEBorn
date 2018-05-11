module Apps.Browser.Pages.DownloadCenter.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Game.Account.Database.Models as Database
import Game.Meta.Types.Network exposing (NIP)
import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp)
import Game.Servers.Shared as Servers
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.DownloadCenter.Config exposing (..)
import Apps.Browser.Pages.DownloadCenter.Messages exposing (..)
import Apps.Browser.Pages.DownloadCenter.Models exposing (..)
import Apps.Browser.Widgets.HackingToolkit.View as HackingToolkit exposing (hackingToolkit)
import Apps.Browser.Widgets.HackingPanel.View as HackingPanel exposing (hackingPanel)
import Apps.Browser.Widgets.PublicFiles.View as PublicFiles exposing (publicFiles)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


hackingToolkitConfig : Config msg -> Bool -> Maybe String -> HackingToolkit.Config msg
hackingToolkitConfig config showPassword fallback =
    { onInput = UpdatePasswordField >> config.toMsg
    , onLogin = config.onLogin
    , onCrack = config.onCrack
    , onAnyMap = config.onAnyMap
    , onEnterPanel = config.toMsg <| SetShowingPanel True
    , showPassword = showPassword
    , fallbackPassword = fallback
    }


publicFilesConfig : Config msg -> NIP -> PublicFiles.Config msg
publicFilesConfig { onPublicDownload } source =
    { onPublicDownload = onPublicDownload source }


hackingPanelConfig : Config msg -> HackingPanel.Config msg
hackingPanelConfig config =
    { batchMsg = config.batchMsg
    , onLogout = config.onLogout
    , onSetEndpoint = config.onSetEndpoint
    , onSelectEndpoint = config.onSelectEndpoint
    , onAnyMap = config.onAnyMap
    , onNewApp = config.onNewApp
    , onSetShowingPanel = SetShowingPanel >> config.toMsg
    , apps =
        [ DesktopApp.TaskManager
        , DesktopApp.ConnManager
        , DesktopApp.LogViewer
        , DesktopApp.Explorer
        ]
    , allowAnyMap = True
    , allowSelectEndpoint = True
    }


view : Config msg -> Model -> Html msg
view config model =
    let
        target =
            model.toolkit.target

        endpointMember =
            List.member (Servers.EndpointCId target) config.endpoints

        fallbackPassword =
            Database.getHackedServer target config.hackedServers
                |> Maybe.map (Database.getPassword)
    in
        if (model.showingPanel && endpointMember) then
            viewPos config target
        else
            viewPre config (not endpointMember) fallbackPassword model


viewPre : Config msg -> Bool -> Maybe String -> Model -> Html msg
viewPre config showPassword fallbackPsw model =
    div [ class [ AutoHeight ] ]
        [ div [ class [ DummyTitle ] ]
            [ text <| "Welcome to " ++ model.title ++ "!" ]
        , publicFiles
            (publicFilesConfig config model.toolkit.target)
            model.publicFiles
        , hackingToolkit
            (hackingToolkitConfig config showPassword fallbackPsw)
            model.toolkit
        ]


viewPos : Config msg -> NIP -> Html msg
viewPos config nip =
    hackingPanel (hackingPanelConfig config) nip
