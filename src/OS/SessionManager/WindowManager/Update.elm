module OS.SessionManager.WindowManager.Update exposing (..)

import Dict
import Utils.React as React exposing (React)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Storyline as Storyline
import Draggable
import Draggable.Events as Draggable
import Utils.Update as Update
import Apps.Update as Apps
import Apps.Messages as Apps
import Game.Meta.Types.Context exposing (Context(..))
import Game.Storyline.Missions.Actions exposing (Action(GoApp))
import OS.SessionManager.WindowManager.Config exposing (..)
import OS.SessionManager.WindowManager.Models exposing (..)
import OS.SessionManager.WindowManager.Messages exposing (Msg(..))


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        AppMsg targetContext id msg ->
            onAppMsg config targetContext id msg model

        EveryAppMsg context msg ->
            onEveryAppMsg config context msg model

        SetContext wId context_ ->
            onSetContext config context_ wId model

        UpdateFocusTo maybeWId ->
            onUpdateFocustTo config maybeWId model

        Close wId ->
            onClose wId model

        ToggleMaximize wId ->
            onToggleMaximize wId model

        Minimize wId ->
            onMinimize wId model

        OnDragBy delta ->
            onDragBy delta model

        DragMsg dragMsg ->
            onDragMsg config dragMsg model

        StartDragging wId ->
            onStartDragging wId model

        StopDragging ->
            onStopDragging model



-- INTERNALS


onAppMsg :
    Config msg
    -> TargetContext
    -> ID
    -> Apps.Msg
    -> Model
    -> ( Model, Cmd msg, Dispatch )
onAppMsg config targetContext wId msg ({ windows } as model) =
    case Dict.get wId windows of
        Just window ->
            model
                |> appsMsg config msg targetContext wId window
                |> Update.mapModel
                    ((flip (Dict.insert wId) windows)
                        >> (\windows_ -> { model | windows = windows_ })
                    )

        Nothing ->
            Update.fromModel model


appsMsg :
    Config msg
    -> Apps.Msg
    -> TargetContext
    -> ID
    -> Window
    -> Model
    -> ( Window, Cmd msg, Dispatch )
appsMsg config msg targetContext wId window model =
    case ( targetContext, window.instance ) of
        ( All, DoubleContext a g e ) ->
            let
                config_ =
                    appsConfig (Just a) wId targetContext config

                ( g_, cmdG, dispatchG ) =
                    Apps.update config_ msg g

                ( e_, cmdE, dispatchE ) =
                    Apps.update config_ msg e

                cmd =
                    [ cmdG, cmdE ]
                        |> Cmd.batch

                dispatch =
                    Dispatch.batch [ dispatchG, dispatchE ]

                window_ =
                    { window | instance = DoubleContext a g_ e_ }
            in
                ( window_, cmd, dispatch )

        ( One Gateway, DoubleContext a g e ) ->
            let
                config_ =
                    appsConfig (Just a) wId targetContext config

                ( g_, cmd, dispatch ) =
                    Apps.update config_ msg g

                window_ =
                    { window | instance = DoubleContext a g_ e }
            in
                ( window_, cmd, dispatch )

        ( One Endpoint, DoubleContext a g e ) ->
            let
                config_ =
                    appsConfig (Just a) wId targetContext config

                ( e_, cmd, dispatch ) =
                    Apps.update config_ msg e

                window_ =
                    { window | instance = DoubleContext a g e_ }
            in
                ( window_, cmd, dispatch )

        ( Active, DoubleContext active _ _ ) ->
            appsMsg config msg (One active) wId window model

        ( _, SingleContext g ) ->
            let
                config_ =
                    appsConfig Nothing wId targetContext config

                ( g_, cmd, dispatch ) =
                    Apps.update config_ msg g

                window_ =
                    { window | instance = SingleContext g_ }
            in
                ( window_, cmd, dispatch )


reduceAppMsg :
    Config msg
    -> TargetContext
    -> Apps.Msg
    -> Model
    -> ID
    -> Window
    -> ( Windows, Cmd msg, Dispatch )
    -> ( Windows, Cmd msg, Dispatch )
reduceAppMsg config context msg model wId window ( windows, cmd0, dispatch0 ) =
    let
        ( window_, cmd1, dispatch1 ) =
            appsMsg config msg context wId window model

        windows_ =
            Dict.insert wId window windows

        cmd =
            Cmd.batch [ cmd0, cmd1 ]

        dispatch =
            Dispatch.batch [ dispatch0, dispatch1 ]
    in
        ( windows_, cmd, dispatch )


onEveryAppMsg :
    Config msg
    -> TargetContext
    -> Apps.Msg
    -> Model
    -> UpdateResponse msg
onEveryAppMsg config context msg model =
    model.windows
        |> Dict.foldl
            (reduceAppMsg config context msg model)
            ( Dict.empty, Cmd.none, Dispatch.none )
        |> Update.mapModel
            (\windows_ -> { model | windows = windows_ })


onSetContext : Config msg -> Context -> ID -> Model -> UpdateResponse msg
onSetContext config context_ wId ({ windows } as model) =
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
                                |> Storyline.ActionDone
                                |> Storyline.Missions
                                |> Dispatch.storyline
                    in
                        ( model_, Cmd.none, dispatch )

                SingleContext _ ->
                    Update.fromModel model

        Nothing ->
            Update.fromModel model


onUpdateFocustTo : Config msg -> Maybe String -> Model -> UpdateResponse msg
onUpdateFocustTo config maybeWId model =
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
                                |> Storyline.ActionDone
                                |> Storyline.Missions
                                |> Dispatch.storyline
                    in
                        ( model_, Cmd.none, dispatch )

                Nothing ->
                    onUnfocus model

        Nothing ->
            onUnfocus model


onUnfocus : Model -> UpdateResponse msg
onUnfocus model =
    model
        |> unfocus
        |> Update.fromModel


onClose : ID -> Model -> UpdateResponse msg
onClose wId model =
    model
        |> remove wId
        |> Update.fromModel


onToggleMaximize : ID -> Model -> UpdateResponse msg
onToggleMaximize wId model =
    model
        |> toggleMaximize wId
        |> Update.fromModel


onMinimize : ID -> Model -> UpdateResponse msg
onMinimize wId model =
    model
        |> minimize wId
        |> Update.fromModel


onDragBy : Draggable.Delta -> Model -> UpdateResponse msg
onDragBy ( x, y ) model =
    Update.fromModel <|
        case model.focusing of
            Just id ->
                move id x y model

            Nothing ->
                model


onDragMsg : Config msg -> Draggable.Msg ID -> Model -> UpdateResponse msg
onDragMsg config msg model =
    let
        dragConfig =
            Draggable.customConfig
                [ Draggable.onDragBy OnDragBy
                , Draggable.onDragStart StartDragging
                ]

        ( model_, cmd ) =
            Draggable.update dragConfig msg model

        cmd_ =
            Cmd.map config.toMsg cmd
    in
        ( model_, cmd_, Dispatch.none )


onStartDragging : ID -> Model -> UpdateResponse msg
onStartDragging wId model =
    model
        |> startDragging wId
        |> Update.fromModel


onStopDragging : Model -> UpdateResponse msg
onStopDragging model =
    model
        |> stopDragging
        |> Update.fromModel
