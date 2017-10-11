module OS.SessionManager.WindowManager.Update exposing (..)

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Draggable
import Draggable.Events as Draggable
import Utils.Update as Update
import Apps.Update as Apps
import Apps.Messages as Apps
import Game.Data as Game
import Game.Meta.Types exposing (Context(..))
import Game.Servers.Models as Servers
import Game.Storyline.Missions.Actions exposing (Action(GoApp))
import OS.SessionManager.WindowManager.Models exposing (..)
import OS.SessionManager.WindowManager.Messages exposing (Msg(..))


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Data -> Msg -> Model -> UpdateResponse
update data msg model =
    case msg of
        AppMsg targetContext id msg ->
            onAppMsg data targetContext id msg model

        EveryAppMsg msg ->
            onEveryAppMsg data msg model

        SetContext wId context_ ->
            onSetContext data context_ wId model

        UpdateFocusTo maybeWId ->
            onUpdateFocustTo data maybeWId model

        Close wId ->
            onClose wId model

        ToggleMaximize wId ->
            onToggleMaximize wId model

        Minimize wId ->
            onMinimize wId model

        OnDragBy delta ->
            onDragBy delta model

        DragMsg dragMsg ->
            onDragMsg dragMsg model

        StartDragging wId ->
            onStartDragging wId model

        StopDragging ->
            onStopDragging model



-- INTERNALS


onAppMsg :
    Game.Data
    -> TargetContext
    -> ID
    -> Apps.Msg
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
onAppMsg data targetContext wId msg ({ windows } as model) =
    case Dict.get wId windows of
        Just window ->
            window
                |> appsMsg data msg targetContext wId
                |> Update.mapModel
                    ((flip (Dict.insert wId) windows)
                        >> (\windows_ -> { model | windows = windows_ })
                    )

        Nothing ->
            Update.fromModel model


appsMsg :
    Game.Data
    -> Apps.Msg
    -> TargetContext
    -> ID
    -> Window
    -> ( Window, Cmd Msg, Dispatch )
appsMsg data msg targetContext wId window =
    case ( targetContext, window.instance ) of
        ( All, DoubleContext a g e ) ->
            let
                ( g_, cmdG, dispatchG ) =
                    Apps.update data msg g

                ( e_, cmdE, dispatchE ) =
                    Apps.update data msg e

                cmd =
                    [ cmdG, cmdE ]
                        |> Cmd.batch
                        |> Cmd.map (AppMsg targetContext wId)

                dispatch =
                    Dispatch.batch [ dispatchG, dispatchE ]

                window_ =
                    { window | instance = DoubleContext a g_ e_ }
            in
                ( window_, cmd, dispatch )

        ( One Gateway, DoubleContext a g e ) ->
            let
                ( g_, cmd, dispatch ) =
                    Apps.update data msg g

                window_ =
                    { window | instance = DoubleContext a g_ e }

                cmd_ =
                    Cmd.map (AppMsg targetContext wId) cmd
            in
                ( window_, cmd_, dispatch )

        ( One Endpoint, DoubleContext a g e ) ->
            let
                ( e_, cmd, dispatch ) =
                    Apps.update data msg e

                window_ =
                    { window | instance = DoubleContext a g e_ }

                cmd_ =
                    Cmd.map (AppMsg targetContext wId) cmd
            in
                ( window_, cmd_, dispatch )

        ( Active, DoubleContext active _ _ ) ->
            appsMsg data msg (One active) wId window

        ( _, SingleContext g ) ->
            let
                ( g_, cmd, dispatch ) =
                    Apps.update data msg g

                window_ =
                    { window | instance = SingleContext g_ }

                cmd_ =
                    Cmd.map (AppMsg (One Gateway) wId) cmd
            in
                ( window_, cmd_, dispatch )


acuAppMsg :
    Game.Data
    -> Apps.Msg
    -> ID
    -> Window
    -> ( Windows, Cmd Msg, Dispatch )
    -> ( Windows, Cmd Msg, Dispatch )
acuAppMsg data msg wId window ( windows, cmd0, dispatch0 ) =
    let
        ( window_, cmd1, dispatch1 ) =
            appsMsg data msg All wId window

        windows_ =
            Dict.insert wId window windows

        cmd =
            Cmd.batch [ cmd0, cmd1 ]

        dispatch =
            Dispatch.batch [ dispatch0, dispatch1 ]
    in
        ( windows_, cmd, dispatch )


onEveryAppMsg : Game.Data -> Apps.Msg -> Model -> UpdateResponse
onEveryAppMsg data msg model =
    model.windows
        |> Dict.foldl
            (acuAppMsg data msg)
            ( Dict.empty, Cmd.none, Dispatch.none )
        |> Update.mapModel
            (\windows_ -> { model | windows = windows_ })


onSetContext : Game.Data -> Context -> ID -> Model -> UpdateResponse
onSetContext data context_ wId ({ windows } as model) =
    case Dict.get wId windows of
        Just ({ instance, app } as window) ->
            case instance of
                DoubleContext _ g e ->
                    let
                        window_ =
                            { window | instance = DoubleContext context_ g e }

                        windows_ =
                            Dict.insert wId window_ windows

                        model_ =
                            { model | windows = windows_ }

                        dispatch =
                            context_
                                |> GoApp app
                                |> Dispatch.missionAction data
                    in
                        ( model_, Cmd.none, dispatch )

                SingleContext _ ->
                    Update.fromModel model

        Nothing ->
            Update.fromModel model


onUpdateFocustTo : Game.Data -> Maybe String -> Model -> UpdateResponse
onUpdateFocustTo data maybeWId model =
    case maybeWId of
        Just id ->
            case Dict.get id model.windows of
                Just window ->
                    let
                        model_ =
                            focus id model

                        dispatch =
                            window
                                |> windowContext
                                |> GoApp window.app
                                |> Dispatch.missionAction data
                    in
                        ( model_, Cmd.none, dispatch )

                Nothing ->
                    onUnfocus model

        Nothing ->
            onUnfocus model


onUnfocus : Model -> UpdateResponse
onUnfocus model =
    model
        |> unfocus
        |> Update.fromModel


onClose : ID -> Model -> UpdateResponse
onClose wId model =
    model
        |> remove wId
        |> Update.fromModel


onToggleMaximize : ID -> Model -> UpdateResponse
onToggleMaximize wId model =
    model
        |> toggleMaximize wId
        |> Update.fromModel


onMinimize : ID -> Model -> UpdateResponse
onMinimize wId model =
    model
        |> minimize wId
        |> Update.fromModel


onDragBy : Draggable.Delta -> Model -> UpdateResponse
onDragBy ( x, y ) model =
    Update.fromModel <|
        case model.focusing of
            Just id ->
                move id x y model

            Nothing ->
                model


onDragMsg : Draggable.Msg ID -> Model -> UpdateResponse
onDragMsg msg model =
    let
        dragConfig =
            Draggable.customConfig
                [ Draggable.onDragBy OnDragBy
                , Draggable.onDragStart StartDragging
                ]

        ( model_, cmd ) =
            Draggable.update dragConfig msg model
    in
        ( model_, cmd, Dispatch.none )


onStartDragging : ID -> Model -> UpdateResponse
onStartDragging wId model =
    model
        |> startDragging wId
        |> Update.fromModel


onStopDragging : Model -> UpdateResponse
onStopDragging model =
    model
        |> stopDragging
        |> Update.fromModel
