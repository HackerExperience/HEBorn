module OS.View exposing (view)

import ContextMenu
import Html as Html exposing (Html, div, text)
import Html.Attributes as Attributes exposing (attribute)
import Html.Events exposing (onClick)
import Html.Lazy exposing (lazy)
import Html.CssHelpers
import Utils.Html.Attributes exposing (activeContextAttr)
import Core.Flags as Flags
import OS.Header.View as Header
import OS.Header.Messages as Header
import OS.Header.Models as Header
import OS.WindowManager.View as WindowManager
import OS.Toasts.View as Toasts
import OS.Console.View as Console
import OS.DynamicStyle as DynamicStyle
import OS.Resources as R
import OS.Config exposing (..)
import OS.Models exposing (..)
import OS.Messages exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace R.prefix


view : Config msg -> Model -> Html msg
view config model =
    let
        version =
            config.flags
                |> Flags.getVersion

        gameMode =
            case isCampaignFromConfig config of
                True ->
                    R.campaignMode

                False ->
                    R.multiplayerMode
    in
        model
            |> viewOS config
            |> (::) (DynamicStyle.view config)
            |> (::) config.menuView
            |> div
                [ id R.Dashboard
                , attribute R.gameVersionAttrTag version
                , attribute R.gameModeAttrTag gameMode
                , activeContextAttr config.activeContext
                , onClick <| config.toMsg <| HeaderMsg <| Header.CheckMenus
                , config.menuAttr
                    [ [ ( ContextMenu.item "Sign out", onSignOut config ) ] ]
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
    WindowManager.view (windowManagerConfig config) (getWindowManager model)


displayVersion : String -> Html msg
displayVersion version =
    div
        [ class [ R.Version ] ]
        [ text version ]


toasts : Config msg -> Model -> Html msg
toasts config model =
    model.toasts
        |> Toasts.view (toastsConfig config)


console : Config msg -> Html msg
console config =
    Console.view (consoleConfig config)
