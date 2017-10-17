module OS.SessionManager.WindowManager.Models
    exposing
        ( Model
        , Windows
        , Index
        , ID
        , Window
        , Position
        , Size
        , Instance(..)
        , TargetContext(..)
        , GroupedWindows
        , initialModel
        , refresh
        , insertLocked
        , remove
        , removeAll
        , focus
        , unfocus
        , restore
        , minimize
        , minimizeAll
        , getContext
        , move
        , resize
        , toggleMaximize
        , toggleLock
        , toggleContext
        , setContext
        , startDragging
        , stopDragging
        , getAppModel
        , getAppModelFromWindow
        , group
        , title
        , windowData
        , windowContext
        , realContext
        , initialPosition
        , filterApp
        , moveTail
        )

import Dict exposing (Dict)
import Draggable
import Apps.Apps as Apps
import Apps.Models as Apps
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Game.Meta.Types exposing (..)
import Game.Data as Game
import Game.Models as Game
import Game.Account.Models as Account


type alias Model =
    { windows : Windows
    , hidden : Index
    , visible : Index
    , drag : Draggable.State ID
    , dragging : Maybe ID
    , focusing : Maybe ID
    , parentSession : ID
    }


type alias Windows =
    Dict ID Window


type alias Index =
    List ID


type alias ID =
    String


type alias Window =
    { position : Position
    , size : Size
    , maximized : Bool
    , app : Apps.App
    , instance : Instance
    , locked : Bool
    , endpoint : Maybe Servers.CId
    }


type alias Position =
    { x : Float
    , y : Float
    }


type alias Size =
    { width : Float
    , height : Float
    }


type Instance
    = DoubleContext Context Apps.AppModel Apps.AppModel -- ACTIVE GATEWAY ENDPOINT
    | SingleContext Apps.AppModel


type TargetContext
    = All
    | One Context
    | Active


type alias GroupedWindows =
    { visible : Dict String (List ( String, Window ))
    , hidden : Dict String (List ( String, Window ))
    }


initialModel : ID -> Model
initialModel parent =
    { windows = Dict.empty
    , hidden = []
    , visible = []
    , drag = Draggable.init
    , dragging = Nothing
    , focusing = Nothing
    , parentSession = parent
    }


refresh : ID -> Window -> Model -> Model
refresh id window ({ windows } as model) =
    case Dict.get id windows of
        Just _ ->
            let
                windows_ =
                    Dict.insert id window windows
            in
                { model | windows = windows_ }

        Nothing ->
            model


insertLocked : ID -> Window -> Model -> Model
insertLocked id window ({ windows, visible } as model) =
    let
        window_ =
            { window | locked = True }

        windows_ =
            Dict.insert id window_ windows

        visible_ =
            moveTail id visible

        model_ =
            { model | windows = windows_, visible = visible_ }
    in
        model_


remove : ID -> Model -> Model
remove id ({ hidden, visible, windows } as model) =
    let
        hidden_ =
            dropElement id hidden

        visible_ =
            dropElement id visible

        windows_ =
            Dict.remove id windows

        model_ =
            { model
                | windows = windows_
                , hidden = hidden_
                , visible = visible_
                , focusing = Nothing
            }
    in
        model_


removeAll : Apps.App -> Model -> Model
removeAll app ({ visible, hidden, windows } as model) =
    -- either restores every app or open a new one
    let
        filter =
            filterApp app windows

        model1 =
            visible
                |> List.filter filter
                |> List.foldl remove model

        model_ =
            hidden
                |> List.filter filter
                |> List.foldl remove model1
    in
        model_


focus : ID -> Model -> Model
focus id ({ visible } as model) =
    let
        visible_ =
            moveTail id visible

        model_ =
            { model | visible = visible_, focusing = Just id }
    in
        model_


unfocus : Model -> Model
unfocus model =
    let
        model_ =
            { model | focusing = Nothing }
    in
        model_


restore : ID -> Model -> Model
restore id ({ hidden, visible } as model) =
    let
        hidden_ =
            dropElement id hidden

        visible_ =
            moveTail id visible

        model_ =
            { model
                | hidden = hidden_
                , visible = visible_
                , focusing = Just id
            }
    in
        model_


minimize : ID -> Model -> Model
minimize id ({ hidden, visible } as model) =
    let
        hidden_ =
            moveTail id hidden

        visible_ =
            dropElement id visible

        model_ =
            { model
                | hidden = hidden_
                , visible = visible_
                , focusing = Nothing
            }
    in
        model_


minimizeAll : Apps.App -> Model -> Model
minimizeAll app ({ visible, windows } as model) =
    -- either restores every app or open a new one
    let
        model_ =
            visible
                |> List.filter (filterApp app windows)
                |> List.foldl minimize model
    in
        model_


windowContext : Window -> Context
windowContext { instance } =
    case instance of
        SingleContext _ ->
            Gateway

        DoubleContext context _ _ ->
            context


realContext : Window -> Maybe Context
realContext { instance } =
    case instance of
        SingleContext _ ->
            Nothing

        DoubleContext context _ _ ->
            Just context


getContext : ID -> Model -> Maybe Context
getContext id model =
    model.windows
        |> Dict.get id
        |> Maybe.map windowContext


move : String -> Float -> Float -> Model -> Model
move id x y ({ windows } as model) =
    case Dict.get id windows of
        Just ({ position } as window) ->
            let
                position_ =
                    Position
                        (position.x + x)
                        (position.y + y)

                window_ =
                    { window | position = position_ }

                windows_ =
                    Dict.insert id window_ windows

                model_ =
                    { model | windows = windows_ }
            in
                model_

        Nothing ->
            model


resize : String -> Float -> Float -> Model -> Model
resize id width height ({ windows } as model) =
    case Dict.get id windows of
        Just window ->
            let
                window_ =
                    { window | size = Size width height }

                windows_ =
                    Dict.insert id window_ windows

                model_ =
                    { model | windows = windows_ }
            in
                model_

        Nothing ->
            model


toggleMaximize : ID -> Model -> Model
toggleMaximize id ({ windows } as model) =
    case Dict.get id windows of
        Just ({ maximized } as window) ->
            let
                window_ =
                    { window | maximized = (not maximized) }

                windows_ =
                    Dict.insert id window_ windows

                model_ =
                    { model
                        | windows = windows_
                        , focusing = Just id
                    }
            in
                model_

        Nothing ->
            model


toggleLock : ID -> Model -> Model
toggleLock id ({ windows } as model) =
    case Dict.get id windows of
        Just ({ locked } as window) ->
            let
                window_ =
                    { window | locked = (not locked) }

                windows_ =
                    Dict.insert id window_ windows

                model_ =
                    { model | windows = windows_ }
            in
                model_

        Nothing ->
            model


toggleContext : ID -> Model -> Model
toggleContext id ({ windows } as model) =
    case Dict.get id windows of
        Just ({ instance } as window) ->
            case instance of
                DoubleContext context g e ->
                    let
                        context_ =
                            case context of
                                Gateway ->
                                    Endpoint

                                Endpoint ->
                                    Gateway

                        window_ =
                            { window
                                | instance = DoubleContext context_ g e
                            }

                        windows_ =
                            Dict.insert id window_ windows

                        model_ =
                            { model | windows = windows_ }
                    in
                        model_

                SingleContext _ ->
                    model

        Nothing ->
            model


setContext : Context -> ID -> Model -> Model
setContext context_ id ({ windows } as model) =
    case Dict.get id windows of
        Just ({ instance } as window) ->
            case instance of
                DoubleContext _ g e ->
                    let
                        window_ =
                            { window
                                | instance = DoubleContext context_ g e
                            }

                        windows_ =
                            Dict.insert id window_ windows

                        model_ =
                            { model | windows = windows_ }
                    in
                        model_

                SingleContext _ ->
                    model

        Nothing ->
            model


startDragging : ID -> Model -> Model
startDragging id model =
    { model | dragging = Just id, focusing = Just id }


stopDragging : Model -> Model
stopDragging model =
    { model | dragging = Nothing }


getAppModel : ID -> Model -> Maybe Apps.AppModel
getAppModel id model =
    case Dict.get id model.windows of
        Just window ->
            Just (getAppModelFromWindow window)

        Nothing ->
            Nothing


getAppModelFromWindow : Window -> Apps.AppModel
getAppModelFromWindow window =
    case window.instance of
        DoubleContext context gateway endpoint ->
            case context of
                Gateway ->
                    gateway

                Endpoint ->
                    endpoint

        SingleContext app ->
            app


group : Model -> GroupedWindows
group { visible, hidden, windows } =
    let
        reducer id dict =
            case Dict.get id windows of
                Just win ->
                    let
                        key =
                            Apps.name win.app
                    in
                        dict
                            |> Dict.get key
                            |> Maybe.withDefault []
                            |> (::) ( id, win )
                            |> flip (Dict.insert key) dict

                Nothing ->
                    dict

        visible_ =
            List.foldl reducer Dict.empty visible

        hidden_ =
            List.foldl reducer Dict.empty hidden

        result =
            { visible = visible_
            , hidden = hidden_
            }
    in
        result


title : Window -> String
title window =
    window
        |> getAppModelFromWindow
        |> Apps.title


windowData :
    Game.Data
    -> Maybe Context
    -> ID
    -> Window
    -> Model
    -> Game.Data
windowData data maybeContext id window model =
    let
        game =
            Game.getGame data

        servers =
            Game.getServers game

        context =
            Maybe.withDefault (windowContext window) maybeContext
    in
        case context of
            Gateway ->
                game
                    |> Game.fromGateway
                    |> Maybe.withDefault data

            Endpoint ->
                window.endpoint
                    |> Maybe.andThen (flip Game.fromServerCId game)
                    |> Maybe.withDefault data


initialPosition : Model -> Position
initialPosition model =
    let
        maybeWindow =
            Maybe.andThen (flip Dict.get model.windows) model.focusing
    in
        case maybeWindow of
            Just win ->
                Position
                    (win.position.x + 32)
                    (win.position.y + 32)

            Nothing ->
                Position
                    32
                    (44 + 32)


filterApp : Apps.App -> Windows -> ID -> Bool
filterApp app windows id =
    case Dict.get id windows of
        Just win ->
            if win.app == app then
                True
            else
                False

        Nothing ->
            False


moveTail : a -> List a -> List a
moveTail target list =
    -- why move tail? because focusing the head would require us to reverse
    --  the list for each view call
    let
        reducer init list =
            case list of
                [] ->
                    init

                head :: tail ->
                    if target == head then
                        List.foldl (::) init tail
                    else
                        reducer (head :: init) tail
    in
        list
            |> List.reverse
            |> reducer [ target ]



-- internals


dropElement : a -> List a -> List a
dropElement target list =
    let
        reducer init list =
            case list of
                [] ->
                    init

                head :: tail ->
                    if target == head then
                        List.foldl (::) init tail
                    else
                        reducer (head :: init) tail
    in
        list
            |> reducer []
            |> List.reverse
