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
import Apps.Browser.Widgets.PublicFiles.View as PublicFiles exposing (publicFiles)
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


view : Game.Data -> Model -> Html Msg
view data model =
    let
        endpointMember =
            List.member
                model.toolkit.target
                data.game.account.joinedEndpoints
    in
        if (model.showingPanel && endpointMember) then
            viewPos data model
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


viewPos : Game.Data -> Model -> Html Msg
viewPos data model =
    ul []
        [ li
            [ onClick <| OpenApp Apps.TaskManagerApp ]
            [ text "Open Task Manager" ]
        , li
            [ onClick <| OpenApp Apps.ConnManagerApp ]
            [ text "Open Connection Manager" ]
        , li
            [ onClick <| OpenApp Apps.LogViewerApp ]
            [ text "Open Log Viewer" ]
        , li
            [ onClick <| OpenApp Apps.ExplorerApp ]
            [ text "Open File Explorer" ]
        , li
            [ onClick <| SelectEndpoint ]
            [ text "Open Remote Desktop" ]
        , li
            [ onClick StartAnyMap ]
            [ text "Start AnyMap" ]
        , li
            [ onClick Logout ]
            [ text "Logout" ]
        , li
            [ onClick <| SetShowingPanel False ]
            [ text "Go back" ]
        ]
        |> List.singleton
        |> div []
