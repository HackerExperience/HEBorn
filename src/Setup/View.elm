module Setup.View exposing (view)

import Game.Models as Game
import Html exposing (..)
import Html.CssHelpers
import Setup.Messages exposing (..)
import Setup.Models exposing (..)
import Setup.Resources exposing (..)
import Setup.Pages.Configs as Configs
import Setup.Pages.Welcome.View as Welcome
import Setup.Pages.CustomWelcome.View as CustomWelcome
import Setup.Pages.Finish.View as Finish
import Setup.Pages.CustomFinish.View as CustomFinish
import Setup.Pages.PickLocation.View as PickLocation
import Setup.Pages.Mainframe.View as Mainframe


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Model -> Model -> Html Msg
view game model =
    if isLoading model then
        loadingView
    else
        case model.page of
            Just page ->
                setupView game page model

            Nothing ->
                loadingView


loadingView : Html Msg
loadingView =
    div []
        [ p [] [ text "Keyboard not found" ]
        , p [] [ text "Press Ctrl+W to quit, keep waiting to continue..." ]
        , br [] []
        , p [] [ text "This is just a joke, game is downloading all yours server data!" ]
        , p [] [ text "This may take a while..." ]
        ]


setupView : Game.Model -> PageModel -> Model -> Html Msg
setupView game page model =
    node setupNode
        []
        [ leftBar page model.pages
        , viewPage game page
        ]


leftBar : PageModel -> List String -> Html Msg
leftBar current others =
    let
        currentPageName =
            pageModelToString current

        mapMarker =
            stepMarker currentPageName
    in
        node leftBarNode
            []
            [ ul [] <| List.map mapMarker others
            ]


viewPage : Game.Model -> PageModel -> Html Msg
viewPage game page =
    case page of
        WelcomeModel ->
            Welcome.view Configs.welcome

        CustomWelcomeModel ->
            CustomWelcome.view Configs.welcome

        MainframeModel model ->
            Mainframe.view Configs.setMainframeName game model

        PickLocationModel model ->
            PickLocation.view Configs.pickLocation game model

        ChooseThemeModel ->
            -- TODO
            div [] []

        FinishModel ->
            Finish.view Configs.finish

        CustomFinishModel ->
            CustomFinish.view Configs.finish


stepMarker : String -> String -> Html Msg
stepMarker active other =
    let
        isSelected =
            if active == other then
                [ class [ Selected ] ]
            else
                []
    in
        li isSelected [ text other ]
