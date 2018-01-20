module OS.View exposing (view)

import Html as Html exposing (Html, div, text)
import Html.Attributes as Attributes exposing (attribute)
import Html.Lazy exposing (lazy)
import Html.CssHelpers
import Utils.Html.Attributes exposing (activeContextAttr)
import Game.Data as Game
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


view : Config msg -> Game.Data -> Model -> Html msg
view config data model =
    let
        osContent =
            viewOS config data model

        game =
            data
                |> Game.getGame

        dynStyle =
            DynamicStyle.view config

        version =
            game
                |> Game.getFlags
                |> Flags.getVersion

        context =
            game
                |> Game.getAccount
                |> Account.getContext

        story =
            game
                |> Game.getStory
                |> Storyline.isActive

        gameMode =
            case story of
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


viewOS : Config msg -> Game.Data -> Model -> List (Html msg)
viewOS config data model =
    let
        version =
            data
                |> Game.getGame
                |> Game.getFlags
                |> Flags.getVersion
    in
        [ viewHeader
            config
            data
            model.header
        , console config data model
        , viewMain config data model
        , toasts config data model
        , lazy displayVersion
            version
        ]


viewHeader : Config msg -> Game.Data -> Header.Model -> Html msg
viewHeader config game header =
    Header.view game header
        |> Html.map (HeaderMsg >> config.toMsg)


viewMain : Config msg -> Game.Data -> Model -> Html msg
viewMain config game model =
    let
        config_ =
            smConfig config
    in
        model.session
            |> SessionManager.view config_ game


displayVersion : String -> Html msg
displayVersion version =
    div
        [ class [ Res.Version ] ]
        [ text version ]


toasts : Config msg -> Game.Data -> Model -> Html msg
toasts config data model =
    model.toasts
        |> Toasts.view data
        |> Html.map (ToastsMsg >> config.toMsg)


console : Config msg -> Game.Data -> Model -> Html msg
console config data model =
    Console.view data
