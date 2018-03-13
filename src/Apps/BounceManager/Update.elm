module Apps.BounceManager.Update exposing (update)

import Utils.React as React exposing (React)
import Utils.List exposing (..)
import Utils.Maybe as Maybe
import Utils.Result exposing (..)
import Utils.Model.RandomUuid as Random
import Game.Account.Bounces.Models as Bounces
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Bounces.Requests.Create exposing (createRequest)
import Game.Account.Bounces.Requests.Update exposing (updateRequest)
import Game.Account.Bounces.Requests.Remove exposing (removeRequest)
import Game.Account.Database.Models as Database
import Game.Meta.Types.Network as Network
import Apps.BounceManager.Config exposing (..)
import Apps.BounceManager.Models exposing (..)
import Apps.BounceManager.Messages as BounceManager exposing (Msg(..))


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> BounceManager.Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        GoTab tab ->
            onGoTab config tab model

        UpdateEditing str ->
            onUpdateEditing str model

        ToggleNameEdit ->
            onToggleNameEdit model

        ApplyNameChangings ->
            onApplyNameChangings model

        SelectServer nip ->
            onSelectServer nip model

        SelectSlot num ->
            onSelectSlot num model

        SelectEntry nip ->
            onSelectEntry nip model

        ClearSelection ->
            onClearSelection model

        AddNode nip where_ ->
            onAddNode nip where_ model

        RemoveNode nip ->
            onRemoveNode nip model

        MoveNode nip where_ ->
            onMoveNode nip where_ model

        Save bounceInfo ->
            onSave config bounceInfo model

        Reset bounceInfo ->
            onReset config bounceInfo model

        Delete bounceId ->
            onDelete config bounceId model

        Edit bounceId ->
            onEdit config bounceId model

        ToggleExpand bounceId ->
            onToggleExpand config bounceId model

        LaunchApp _ ->
            --TODO: Implement open BounceManager with preset Bounce
            ( model, React.none )

        SetModal modal ->
            onSetModal config modal model

        CreateRequest response ->
            onCreateRequest config response model

        UpdateRequest response ->
            onUpdateRequest config response model

        RemoveRequest response ->
            onRemoveRequest config response model

        SetInitialSeed seed ->
            onSetInitialSeed seed model


onSetInitialSeed : Int -> Model -> UpdateResponse msg
onSetInitialSeed seed model =
    ( Random.setSeed seed model, React.none )


onGoTab : Config msg -> MainTab -> Model -> UpdateResponse msg
onGoTab config tab model =
    case tab of
        TabBuild ( maybeId, bounce ) ->
            let
                model_ =
                    model
                        |> setSelectedTab tab
                        |> setNewPath config maybeId
                        |> setSelectedBounce (Just ( maybeId, bounce ))
            in
                ( model_, React.none )

        _ ->
            let
                model_ =
                    { model | selected = tab }
            in
                ( model_, React.none )


setNewPath : Config msg -> Maybe String -> Model -> Model
setNewPath { bounces } maybeId model =
    case maybeId of
        Just id ->
            case Bounces.getPath id bounces of
                Just path ->
                    if path /= model.path then
                        setPath model.path model
                    else
                        setPath path model

                Nothing ->
                    setPath model.path model

        Nothing ->
            setPath model.path model


onUpdateEditing : String -> Model -> UpdateResponse msg
onUpdateEditing str model =
    let
        model_ =
            { model | bounceNameBuffer = Just str }
    in
        ( model_, React.none )


onToggleNameEdit : Model -> UpdateResponse msg
onToggleNameEdit model =
    let
        model_ =
            { model
                | renaming = not model.renaming
                , bounceNameBuffer = Nothing
            }
    in
        ( model_, React.none )


onApplyNameChangings : Model -> UpdateResponse msg
onApplyNameChangings model =
    let
        model_ =
            { model
                | renaming = False
                , anyChange = True
            }
    in
        ( model_, React.none )


onSelectServer : Network.NIP -> Model -> UpdateResponse msg
onSelectServer nip model =
    let
        model_ =
            { model | selection = Just (SelectingServer nip) }
    in
        ( model_, React.none )


onSelectSlot : Int -> Model -> UpdateResponse msg
onSelectSlot num model =
    let
        model_ =
            { model | selection = Just (SelectingSlot num) }
    in
        ( model_, React.none )


onSelectEntry : Network.NIP -> Model -> UpdateResponse msg
onSelectEntry nip model =
    let
        model_ =
            { model | selection = Just (SelectingEntry nip) }
    in
        ( model_, React.none )


onClearSelection : Model -> UpdateResponse msg
onClearSelection model =
    let
        model_ =
            { model | selection = Nothing }
    in
        ( model_, React.none )


onAddNode : Network.NIP -> Int -> Model -> UpdateResponse msg
onAddNode nip where_ model =
    let
        path =
            insertAt where_ nip model.path

        model_ =
            { model | path = path, selection = Nothing, anyChange = True }
    in
        ( model_, React.none )


onMoveNode : Network.NIP -> Int -> Model -> UpdateResponse msg
onMoveNode nip where_ model =
    let
        path =
            nip
                |> (\nip -> List.filter (((==) nip) >> not) model.path)
                |> insertAt where_ nip

        model_ =
            { model | path = path, selection = Nothing, anyChange = True }
    in
        ( model_, React.none )


onRemoveNode : Network.NIP -> Model -> UpdateResponse msg
onRemoveNode nip model =
    let
        path_ =
            List.filter (((==) nip) >> not) model.path

        model_ =
            { model | path = path_, selection = Nothing, anyChange = True }
    in
        ( model_, React.none )


onSave :
    Config msg
    -> ( Maybe Bounces.ID, Bounces.Bounce )
    -> Model
    -> UpdateResponse msg
onSave ({ toMsg, accountId, bounces, database } as config) ( id, bounce ) model =
    let
        hackedServers =
            Database.getHackedServers database

        getBounce maybeId =
            Maybe.andThen (flip Bounces.get bounces) maybeId

        ( model0, rId ) =
            Random.newUuid model

        setSpinner =
            React.msg <| toMsg <| SetModal Nothing

        successMsg =
            toMsg <| SetModal <| Just ForSaveSucessful

        failMsg isCreate =
            if isCreate then
                Bounces.CreateFailed
                    |> CreateError
                    |> ForError
                    |> Just
                    |> SetModal
                    |> toMsg
            else
                Bounces.UpdateFailed
                    |> UpdateError
                    |> ForError
                    |> Just
                    |> SetModal
                    |> toMsg

        name =
            model.bounceNameBuffer
                |> Maybe.withDefault bounce.name

        newBounce =
            { name = name, path = model.path }

        react =
            case Maybe.uncurry id (getBounce id) of
                Just ( id, bounce_ ) ->
                    if (bounce_ /= newBounce) then
                        React.batch config.batchMsg
                            [ rId
                                |> doUpdateRequest config hackedServers id bounce
                            , setSpinner
                            , ( "bounce_updated", successMsg )
                                |> config.awaitEvent rId
                                |> React.msg
                            , ( "bounce_update_failed", (failMsg False) )
                                |> config.awaitEvent rId
                                |> React.msg
                            ]
                    else
                        React.none

                Nothing ->
                    React.batch config.batchMsg
                        [ rId
                            |> doCreateRequest config hackedServers newBounce
                        , setSpinner
                        , ( "bounce_created", successMsg )
                            |> config.awaitEvent rId
                            |> React.msg
                        , ( "bounce_create_failed"
                          , (failMsg True)
                          )
                            |> config.awaitEvent rId
                            |> React.msg
                        ]
    in
        ( model0, react )


onReset :
    Config msg
    -> ( Maybe Bounces.ID, Bounces.Bounce )
    -> Model
    -> UpdateResponse msg
onReset ({ bounces } as config) ( id, bounce ) model =
    let
        selected =
            Maybe.withDefault emptyBounceBuildTab <| bounceExist config id

        model_ =
            reset selected model
    in
        ( model_, React.none )


onDelete :
    Config msg
    -> Maybe Bounces.ID
    -> Model
    -> UpdateResponse msg
onDelete config bounceId model =
    case bounceId of
        Just id ->
            let
                model_ =
                    { model
                        | selected = TabManage
                        , selectedBounce = Nothing
                    }

                react =
                    doRemoveRequest config id
            in
                ( model_, react )

        Nothing ->
            let
                model_ =
                    { model
                        | selected = TabManage
                        , selectedBounce = Nothing
                        , path = []
                        , bounceNameBuffer = Nothing
                        , anyChange = False
                    }
            in
                ( model_, React.none )


bounceExist : Config msg -> Maybe Bounces.ID -> Maybe MainTab
bounceExist { bounces } id =
    case id of
        Just id ->
            case Bounces.get id bounces of
                Just bounce ->
                    Just <| TabBuild ( Just id, bounce )

                Nothing ->
                    Nothing

        Nothing ->
            Nothing


onEdit : Config msg -> Bounces.ID -> Model -> UpdateResponse msg
onEdit config bounceId model =
    let
        model_ =
            case Bounces.get bounceId config.bounces of
                Just bounce ->
                    { model
                        | selected = TabBuild ( Just bounceId, bounce )
                        , selectedBounce = Just ( Just bounceId, bounce )
                        , path = bounce.path
                    }

                Nothing ->
                    model
    in
        ( model_, React.none )


onToggleExpand : Config msg -> Bounces.ID -> Model -> UpdateResponse msg
onToggleExpand config bounceId model =
    let
        newExpanded =
            if (List.member bounceId model.expanded) then
                List.filter ((==) bounceId >> not) model.expanded
            else
                (::) bounceId model.expanded

        model_ =
            { model | expanded = newExpanded }
    in
        ( model_, React.none )


onSetModal : Config msg -> Maybe ModalAction -> Model -> UpdateResponse msg
onSetModal config modal model =
    let
        model_ =
            case modal of
                Just ForSaveSucessful ->
                    { model | modal = modal, anyChange = False }

                _ ->
                    { model | modal = modal }
    in
        ( model_, React.none )


onCreateRequest :
    Config msg
    -> Maybe Bounces.CreateError
    -> Model
    -> UpdateResponse msg
onCreateRequest config response model =
    let
        model_ =
            case response of
                Nothing ->
                    model

                Just error ->
                    { model | modal = Just <| ForError (CreateError error) }
    in
        ( model_, React.none )


onUpdateRequest :
    Config msg
    -> Maybe Bounces.UpdateError
    -> Model
    -> UpdateResponse msg
onUpdateRequest config response model =
    let
        model_ =
            case response of
                Nothing ->
                    model

                Just error ->
                    { model | modal = Just <| ForError (UpdateError error) }
    in
        ( model_, React.none )


onRemoveRequest :
    Config msg
    -> Maybe Bounces.RemoveError
    -> Model
    -> UpdateResponse msg
onRemoveRequest config response model =
    let
        model_ =
            case response of
                Nothing ->
                    { model
                        | selected = TabManage
                        , selectedBounce = Nothing
                        , path = []
                        , bounceNameBuffer = Nothing
                        , anyChange = False
                    }

                Just error ->
                    { model | modal = Just <| ForError (RemoveError error) }
    in
        ( model_, React.none )



-- CreateRequest


doCreateRequest :
    Config msg
    -> Database.HackedServers
    -> Bounces.Bounce
    -> String
    -> React msg
doCreateRequest ({ toMsg, accountId } as config) hackedServers bounce rId =
    let
        _ =
            Debug.log "Create Request ID" rId
    in
        config
            |> createRequest hackedServers bounce accountId rId
            |> Cmd.map (errorToMaybe >> CreateRequest >> toMsg)
            |> React.cmd



-- UpdateRequest


doUpdateRequest :
    Config msg
    -> Database.HackedServers
    -> Bounces.ID
    -> Bounces.Bounce
    -> String
    -> React msg
doUpdateRequest ({ toMsg, accountId } as config) hackedServers id bounce rId =
    let
        _ =
            Debug.log "Update Request ID" rId
    in
        config
            |> updateRequest hackedServers id bounce accountId rId
            |> Cmd.map (errorToMaybe >> UpdateRequest >> toMsg)
            |> React.cmd



-- RemoveRequest


doRemoveRequest :
    Config msg
    -> Bounces.ID
    -> React msg
doRemoveRequest ({ toMsg, accountId } as config) id =
    config
        |> removeRequest id accountId
        |> Cmd.map (errorToMaybe >> RemoveRequest >> toMsg)
        |> React.cmd
