module Setup.Models exposing (..)

import Game.Models as Game
import Game.Servers.Settings.Types as Settings exposing (Settings)
import Json.Encode as Encode exposing (Value)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Ports.Map exposing (Coordinates)
import Setup.Types exposing (..)
import Setup.Messages exposing (Msg)
import Setup.Pages.PickLocation.Models as PickLocation
import Setup.Pages.Mainframe.Models as Mainframe


type alias Model =
    { page : Maybe PageModel
    , pages : List String
    , remaining : List PageModel
    , done : PagesDone
    , isLoading : Bool
    }


type PageModel
    = WelcomeModel
    | CustomWelcomeModel
    | MainframeModel Mainframe.Model
    | PickLocationModel PickLocation.Model
    | ChooseThemeModel
    | FinishModel
    | CustomFinishModel


type alias PagesDone =
    List ( PageModel, List Settings )


mapId : String
mapId =
    "map-setup"


geoInstance : String
geoInstance =
    "setup"


pageOrder : Pages
pageOrder =
    [ Welcome
    , Mainframe
    , PickLocation
    , Finish
    ]


remainingPages : Pages -> Pages
remainingPages pages =
    let
        newPages =
            List.filter ((flip List.member pages) >> not) pageOrder
    in
        case List.head newPages of
            Just Welcome ->
                -- insert local greetings/farewells
                newPages
                    |> List.reverse
                    |> (::) CustomFinish
                    |> List.reverse
                    |> (::) CustomWelcome

            _ ->
                newPages


initializePages : Pages -> List PageModel
initializePages =
    let
        mapper page =
            case page of
                Welcome ->
                    WelcomeModel

                CustomWelcome ->
                    CustomWelcomeModel

                Mainframe ->
                    MainframeModel <| Mainframe.initialModel

                PickLocation ->
                    PickLocationModel <| PickLocation.initialModel

                ChooseTheme ->
                    ChooseThemeModel

                Finish ->
                    FinishModel

                CustomFinish ->
                    CustomFinishModel
    in
        List.map mapper


initialModel : Game.Model -> ( Model, Cmd Msg, Dispatch )
initialModel game =
    let
        model =
            { page = Nothing
            , pages = []
            , remaining = []
            , done = []
            , isLoading = True
            }
    in
        ( model, Cmd.none, Dispatch.none )


doneLoading : Model -> Model
doneLoading model =
    { model | isLoading = False }


doneSetup : Model -> Bool
doneSetup model =
    case model.page of
        Just _ ->
            False

        Nothing ->
            List.isEmpty model.remaining


isLoading : Model -> Bool
isLoading =
    .isLoading


hasPages : Model -> Bool
hasPages =
    .pages >> List.isEmpty


setPages : Pages -> Model -> Model
setPages pages model =
    let
        models =
            initializePages pages

        remaining =
            models
                |> List.tail
                |> Maybe.withDefault []
    in
        { model
            | pages = List.map pageModelToString models
            , page = List.head models
            , remaining = remaining
        }


setPage : PageModel -> Model -> Model
setPage page model =
    { model | page = Just page }


nextPage : List Settings -> Model -> Model
nextPage settings model =
    let
        current =
            List.head model.remaining

        remaining =
            model.remaining
                |> List.tail
                |> Maybe.withDefault []

        done =
            case model.page of
                Just page ->
                    ( page, settings ) :: model.done

                Nothing ->
                    model.done

        model_ =
            { model
                | page = current
                , remaining = remaining
                , done = done
            }
    in
        model_


previousPage : Model -> Model
previousPage model =
    let
        current =
            model.done
                |> List.head
                |> Maybe.map Tuple.first

        done =
            model.done
                |> List.tail
                |> Maybe.withDefault []

        remaining =
            case model.page of
                Just page ->
                    page :: model.remaining

                Nothing ->
                    model.remaining

        model_ =
            { model
                | page = current
                , remaining = remaining
                , done = done
            }
    in
        model_


pageModelToString : PageModel -> String
pageModelToString page =
    case page of
        WelcomeModel ->
            "WELCOME"

        CustomWelcomeModel ->
            "WELCOME AGAIN"

        MainframeModel _ ->
            "MAINFRAME"

        PickLocationModel _ ->
            "LOCATION PICKER"

        ChooseThemeModel ->
            "CHOOSE THEME"

        FinishModel ->
            "FINISH"

        CustomFinishModel ->
            "FINISH"


encodeDone : Model -> Result String (List Value)
encodeDone =
    let
        skipEmpty model =
            if List.isEmpty model.done then
                Err "No setup pages to encode."
            else
                Ok model.done

        encodePages ( page, _ ) list =
            case list of
                Ok list ->
                    case encodePageModel page of
                        Ok page ->
                            Ok <| page :: list

                        Err msg ->
                            Err msg

                Err _ ->
                    list
    in
        skipEmpty >> Result.andThen (List.foldl encodePages (Ok []))


encodePageModel : PageModel -> Result String Value
encodePageModel page =
    case page of
        WelcomeModel ->
            Ok <| Encode.string "welcome"

        MainframeModel _ ->
            Ok <| Encode.string "mainframe"

        PickLocationModel _ ->
            Ok <| Encode.string "location_picker"

        ChooseThemeModel ->
            Ok <| Encode.string "theme_selector"

        FinishModel ->
            Ok <| Encode.string "finish"

        _ ->
            Err
                ("Can't convert page `"
                    ++ (pageModelToString page)
                    ++ "' to json, this is a local page."
                )
