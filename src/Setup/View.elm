module Setup.View exposing (view)

import Game.Models as Game
import Html exposing (..)
import Html.CssHelpers
import Setup.Messages exposing (..)
import Setup.Models exposing (..)
import Setup.Resources exposing (..)
import Setup.Config exposing (..)
import Setup.Pages.Welcome.View as Welcome
import Setup.Pages.CustomWelcome.View as CustomWelcome
import Setup.Pages.Finish.View as Finish
import Setup.Pages.CustomFinish.View as CustomFinish
import Setup.Pages.PickLocation.View as PickLocation
import Setup.Pages.Mainframe.View as Mainframe


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config model =
    if isLoading model then
        loadingView
    else
        case model.page of
            Just page ->
                setupView config page model

            Nothing ->
                loadingView


loadingView : Html msg
loadingView =
    div []
        [ p [] [ text "Keyboard not found" ]
        , p [] [ text "Press Ctrl+W to quit, keep waiting to continue..." ]
        , br [] []
        , p [] [ text "This is just a joke, game is downloading all yours server data!" ]
        , p [] [ text "This may take a while..." ]
        ]


setupView : Config msg -> PageModel -> Model -> Html msg
setupView config page model =
    node setupNode
        []
        [ leftBar page model.pages
        , viewPage config page
        ]


leftBar : PageModel -> List String -> Html msg
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


viewPage : Config msg -> PageModel -> Html msg
viewPage ({ flags, mainframe } as config) page =
    case page of
        WelcomeModel ->
            Welcome.view (welcomeConfig config)

        CustomWelcomeModel ->
            CustomWelcome.view (welcomeConfig config)

        MainframeModel model ->
            Mainframe.view (mainframeConfig config) model

        PickLocationModel model ->
            PickLocation.view (pickLocationConfig config) model

        ChooseThemeModel ->
            -- TODO
            div [] []

        FinishModel ->
            Finish.view (finishConfig config)

        CustomFinishModel ->
            CustomFinish.view (finishConfig config)


stepMarker : String -> String -> Html msg
stepMarker active other =
    let
        isSelected =
            if active == other then
                [ class [ Selected ] ]
            else
                []
    in
        li isSelected [ text other ]
