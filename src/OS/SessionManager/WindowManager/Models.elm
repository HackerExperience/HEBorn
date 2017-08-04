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
        , GroupedWindows
        , initialModel
        , resert
        , insert
        , refresh
        , insertLocked
        , remove
        , removeAll
        , focus
        , unfocus
        , restore
        , minimize
        , minimizeAll
        , context
        , move
        , resize
        , toggleMaximize
        , toggleLock
        , toggleContext
        , startDragging
        , stopDragging
        , getAppModel
        , setAppModel
        , getAppModelFromWindow
        , group
        , title
        , windowData
        )

import Dict exposing (Dict)
import Draggable
import Apps.Apps as Apps
import Apps.Models as Apps
import Game.Network.Types exposing (NIP)
import Game.Servers.Models as Servers
import Game.Meta.Types exposing (..)
import OS.SessionManager.WindowManager.Messages exposing (..)
import Game.Data as Game
import Game.Models as Game
import Game.Meta.Models as Meta
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias Model =
    { windows : Windows
    , hidden : Index
    , visible : Index
    , drag : Draggable.State ID
    , dragging : Maybe ID
    , focusing : Maybe ID
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
    , context : Maybe Context
    , instance : Instance
    , locked : Bool
    , endpoint : Maybe NIP
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
    = DoubleContext Apps.AppModel Apps.AppModel
    | SingleContext Apps.AppModel


type alias GroupedWindows =
    { visible : Dict String (List ( String, Window ))
    , hidden : Dict String (List ( String, Window ))
    }


initialModel : Model
initialModel =
    { windows = Dict.empty
    , hidden = []
    , visible = []
    , drag = Draggable.init
    , dragging = Nothing
    , focusing = Nothing
    }


resert :
    Game.Data
    -> String
    -> Maybe NIP
    -> Apps.App
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
resert data id nip app ({ visible, hidden, windows } as model) =
    let
        noVisible =
            visible
                |> List.filter (filterApp app windows)
                |> List.isEmpty

        noHidden =
            hidden
                |> List.filter (filterApp app windows)
                |> List.isEmpty

        noOpened =
            noVisible && noHidden
    in
        if noOpened then
            insert data id nip app model
        else if noVisible then
            let
                model_ =
                    hidden
                        |> List.filter (filterApp app windows)
                        |> List.foldl restore model
            in
                ( model_, Cmd.none, Dispatch.none )
        else
            insert data id nip app model


insert :
    Game.Data
    -> ID
    -> Maybe NIP
    -> Apps.App
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
insert data id nip app ({ windows, visible } as model) =
    let
        contexts =
            case Apps.contexts app of
                Apps.ContextualApp ->
                    data
                        |> Game.getGame
                        |> Game.getMeta
                        |> Meta.getContext
                        |> Just

                Apps.ContextlessApp ->
                    Nothing

        ( instance, cmd, dispatch ) =
            case Apps.contexts app of
                Apps.ContextualApp ->
                    let
                        ( model1, cmd1, dispatch1 ) =
                            Apps.model data id app

                        data_ =
                            data
                                |> Game.getGame
                                |> Game.fromEndpoint
                                |> Maybe.withDefault data

                        ( model2, cmd2, dispatch2 ) =
                            Apps.model data_ id app

                        cmd =
                            Cmd.batch [ cmd1, cmd2 ]

                        dispatch =
                            Dispatch.batch [ dispatch1, dispatch2 ]

                        model3 =
                            case contexts of
                                Just Gateway ->
                                    DoubleContext model1 model2

                                _ ->
                                    DoubleContext model2 model1
                    in
                        ( model3, cmd, dispatch )

                Apps.ContextlessApp ->
                    let
                        ( model, cmd, dispatch ) =
                            Apps.model data id app
                    in
                        ( SingleContext model, cmd, dispatch )

        cmd_ =
            Cmd.map (WindowMsg id) cmd

        window =
            Window
                (initialPosition model)
                (Size 600 400)
                False
                app
                contexts
                instance
                False
                nip

        windows_ =
            Dict.insert id window windows

        visible_ =
            moveTail id visible

        model_ =
            { model
                | windows = windows_
                , visible = visible_
                , focusing = Just id
            }
    in
        ( model_, cmd_, dispatch )


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


context : ID -> Model -> Maybe Context
context id model =
    model.windows
        |> Dict.get id
        |> Maybe.andThen .context


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
                    { model | windows = windows_ }
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
        Just ({ context, instance } as window) ->
            case instance of
                DoubleContext a b ->
                    let
                        instance_ =
                            DoubleContext b a

                        context_ =
                            case context of
                                Just Gateway ->
                                    Just Endpoint

                                Just Endpoint ->
                                    Just Gateway

                                Nothing ->
                                    Nothing

                        window_ =
                            { window
                                | instance = instance_
                                , context = context_
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


setAppModel : ID -> Apps.AppModel -> Model -> Model
setAppModel id app ({ windows } as model) =
    case Dict.get id model.windows of
        Just window ->
            case window.instance of
                DoubleContext left right ->
                    let
                        window_ =
                            { window | instance = DoubleContext app right }

                        windows_ =
                            Dict.insert id window_ windows

                        model_ =
                            { model | windows = windows_ }
                    in
                        model_

                SingleContext _ ->
                    let
                        window_ =
                            { window | instance = SingleContext app }

                        windows_ =
                            Dict.insert id window_ windows

                        model_ =
                            { model | windows = windows_ }
                    in
                        model_

        Nothing ->
            model


getAppModelFromWindow : Window -> Apps.AppModel
getAppModelFromWindow window =
    case window.instance of
        DoubleContext app _ ->
            app

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
    -> ID
    -> Window
    -> Model
    -> Game.Data
windowData data id window model =
    let
        game =
            Game.getGame data

        servers =
            Game.getServers game
    in
        case context id model of
            Just Gateway ->
                game
                    |> Game.fromGateway
                    |> Maybe.withDefault data

            Just Endpoint ->
                window.endpoint
                    |> Maybe.andThen (flip Servers.mapNetwork servers)
                    |> Maybe.andThen (flip Game.fromServerID game)
                    |> Maybe.withDefault data

            Nothing ->
                data



-- internals


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
