module Setup.Models exposing (..)

import Game.Models as Game
import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Ports.Map exposing (Coordinates)
import Setup.Types exposing (..)
import Setup.Messages exposing (Msg)


type alias Model =
    { page : Maybe PageModel
    , pages : List PageModel
    , coordinates : Maybe Coordinates
    , areaLabel : Maybe String
    , isLoading : Bool
    }


type PageModel
    = WelcomeModel
    | CustomWelcomeModel
    | SetHostnameModel String
    | PickLocationModel
    | ChooseThemeModel
    | FinishModel


mapId : String
mapId =
    "map-setup"


geoInstance : String
geoInstance =
    "setup"


pageOrder : Pages
pageOrder =
    [ Welcome
    , PickLocation
    , Finish
    ]


remainingPages : Pages -> Pages
remainingPages pages =
    List.filter ((flip List.member pages) >> not) pageOrder


initializePages : Pages -> List PageModel
initializePages =
    let
        mapper page =
            case page of
                Welcome ->
                    WelcomeModel

                CustomWelcome ->
                    CustomWelcomeModel

                SetHostname ->
                    SetHostnameModel ""

                PickLocation ->
                    PickLocationModel

                ChooseTheme ->
                    ChooseThemeModel

                Finish ->
                    FinishModel
    in
        List.map mapper


initialModel : Game.Model -> ( Model, Cmd Msg, Dispatch )
initialModel game =
    let
        model =
            { page = Nothing
            , pages = []
            , coordinates = Nothing
            , areaLabel = Nothing
            , isLoading = True
            }
    in
        ( model, Cmd.none, Dispatch.none )


setCoords : Maybe Coordinates -> Model -> Model
setCoords coordinates model =
    let
        model_ =
            { model | coordinates = coordinates }
    in
        model_


setAreaLabel : Maybe String -> Model -> Model
setAreaLabel areaLabel model =
    let
        model_ =
            { model | areaLabel = areaLabel }
    in
        model_


setPage : PageModel -> Model -> Model
setPage page model =
    { model | page = Just page }


isLoading : Model -> Bool
isLoading =
    .isLoading


pageModelToString : PageModel -> String
pageModelToString page =
    case page of
        WelcomeModel ->
            "WELCOME"

        CustomWelcomeModel ->
            "NEW FEATURES"

        SetHostnameModel _ ->
            "HOSTNAME"

        PickLocationModel ->
            "LOCATION PICKER"

        ChooseThemeModel ->
            "CHOOSE THEME"

        FinishModel ->
            "FINISH"
