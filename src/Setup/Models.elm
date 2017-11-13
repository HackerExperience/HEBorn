module Setup.Models exposing (..)

import Dict as Dict
import Game.Models as Game
import Json.Encode as Encode exposing (Value)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Setup.Types exposing (..)
import Setup.Messages exposing (Msg)
import Setup.Settings as Settings exposing (Settings)
import Setup.Pages.PickLocation.Models as PickLocation
import Setup.Pages.Mainframe.Models as Mainframe


type alias Model =
    { page : Maybe PageModel
    , pages : List String
    , badPages : List String
    , remaining : List PageModel
    , done : PagesDone
    , isLoading : Bool
    , topicsDone : TopicsDone
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


type alias TopicsDone =
    { server : Bool
    }


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
            , badPages = []
            , remaining = []
            , done = []
            , isLoading = True
            , topicsDone = initialTopicsDone
            }
    in
        ( model, Cmd.none, Dispatch.none )


initialTopicsDone : TopicsDone
initialTopicsDone =
    { server = True
    }


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


setBadPages : List String -> Model -> Model
setBadPages pages model =
    { model | badPages = pages }


setPage : PageModel -> Model -> Model
setPage page model =
    { model | page = Just page }


getDone : Model -> PagesDone
getDone =
    .done


setTopicsDone : Settings.SettingTopic -> Bool -> Model -> Model
setTopicsDone setting value ({ topicsDone } as model) =
    case setting of
        Settings.ServerTopic ->
            { model | topicsDone = { topicsDone | server = value } }

        _ ->
            model


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
        pagesDone =
            getDone model

        current =
            pagesDone
                |> List.head
                |> Maybe.map Tuple.first

        done =
            pagesDone
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


undoPages : Model -> Model
undoPages model =
    let
        pages =
            getDone model
                |> List.map Tuple.first
                |> List.reverse
    in
        { model
            | done = []
            , page = List.head pages
            , remaining = List.drop 1 pages
        }


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


encodeDone : List PageModel -> List Value
encodeDone =
    let
        encodePages page list =
            case encodePageModel page of
                Ok page ->
                    page :: list

                Err msg ->
                    list
    in
        List.foldl encodePages []


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


noTopicsRemaining : Model -> Bool
noTopicsRemaining { topicsDone } =
    topicsDone.server
