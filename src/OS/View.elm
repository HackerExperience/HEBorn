module OS.View exposing (view)

import Html as Html exposing (Html, div, text)
import Html.Attributes as Attributes exposing (attribute)
import Html.Lazy exposing (lazy)
import Html.CssHelpers
import Utils.Html.Attributes exposing (activeContextAttr)
import Game.Models as Game
import Game.Account.Models as Account
import Game.Storyline.Models as Storyline
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
        osContent =
            viewOS config model

        dynStyle =
            DynamicStyle.view config

        version =
            config.flags
                |> Flags.getVersion

        context =
            config.activeContext

        story =
            config.story

        gameMode =
            case Storyline.isActive story of
                True ->
                    Res.campaignMode

                False ->
                    Res.multiplayerMode
    in
        div
            [ id Res.Dashboard
            , attribute Res.gameVersionAttrTag version
            , attribute Res.gameModeAttrTag gameMode
            , activeContextAttr context
            ]
            (dynStyle :: osContent)


viewOS : Config msg -> Model -> List (Html msg)
viewOS config model =
    let
        version =
            config.flags
                |> Flags.getVersion
    in
        [ viewHeader config model.header
        , console config
        , viewMain config model
        , toasts config model
        , lazy displayVersion
            version
        ]


viewHeader : Config msg -> Header.Model -> Html msg
viewHeader config header =
    let
        config_ =
            headerConfig config
    in
        Header.view config_ header
            |> Html.map (HeaderMsg >> config.toMsg)


viewMain : Config msg -> Model -> Html msg
viewMain config model =
    let
        config_ =
            smConfig config
    in
        model.session
            |> SessionManager.view config_


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
    let
        config_ =
            consoleConfig config
    in
        Console.view config_
