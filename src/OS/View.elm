module OS.View exposing (view)

import ContextMenu
import Html as Html exposing (Html, div, text)
import Html.Attributes as Attributes exposing (attribute)
import Html.Lazy exposing (lazy)
import Html.CssHelpers
import Utils.Html.Attributes exposing (activeContextAttr)
import Core.Flags as Flags
import OS.Config exposing (..)
import OS.Models exposing (Model)
import OS.Messages exposing (Msg(..))
import OS.Resources as Res
import OS.DynamicStyle as DynamicStyle
import OS.Header.View as Header
import OS.Header.Models as Header
import OS.SessionManager.View as SessionManager
import OS.Toasts.View as Toasts
import OS.Console.View as Console


{ id, class, classList } =
    Html.CssHelpers.withNamespace Res.prefix


view : Config msg -> Model -> Html msg
view config model =
    let
        version =
            config.flags
                |> Flags.getVersion

        gameMode =
            case config.isCampaign of
                True ->
                    Res.campaignMode

                False ->
                    Res.multiplayerMode
    in
        model
            |> viewOS config
            |> (::) (DynamicStyle.view config)
            |> (::) config.menuView
            |> div
                [ id Res.Dashboard
                , attribute Res.gameVersionAttrTag version
                , attribute Res.gameModeAttrTag gameMode
                , activeContextAttr config.activeContext
                , config.menuAttr
                    [ [ ( ContextMenu.item "Logout", config.onLogout ) ] ]
                ]


viewOS : Config msg -> Model -> List (Html msg)
viewOS config model =
    [ viewHeader config model.header
    , console config
    , viewMain config model
    , toasts config model
    , lazy (Flags.getVersion >> displayVersion) config.flags
    ]


viewHeader : Config msg -> Header.Model -> Html msg
viewHeader config header =
    Header.view (headerConfig config) header


viewMain : Config msg -> Model -> Html msg
viewMain config model =
    model.session
        |> SessionManager.view (smConfig config)


displayVersion : String -> Html msg
displayVersion version =
    div
        [ class [ Res.Version ] ]
        [ text version ]


toasts : Config msg -> Model -> Html msg
toasts config model =
    model.toasts
        |> Toasts.view
        |> Html.map (ToastsMsg >> config.toMsg)


console : Config msg -> Html msg
console config =
    Console.view (consoleConfig config)
