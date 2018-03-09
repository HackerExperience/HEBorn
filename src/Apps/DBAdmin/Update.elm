module Apps.DBAdmin.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Servers.Logs.Models exposing (ID)
import Apps.DBAdmin.Config exposing (..)
import Apps.DBAdmin.Models exposing (..)
import Apps.DBAdmin.Tabs exposing (..)
import Apps.DBAdmin.Messages as DBAdmin exposing (Msg(..))
import Apps.DBAdmin.Tabs.Servers.Helpers as Servers


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> DBAdmin.Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        ToogleExpand tab itemId ->
            onToogleExpand tab itemId model

        EnterEditing tab itemId ->
            onEnterEditing config tab itemId model

        LeaveEditing tab itemId ->
            onLeaveEditing tab itemId model

        UpdateTextFilter tab filter ->
            onUpdateTextFilter config tab filter model

        GoTab tab ->
            onGoTab tab model

        _ ->
            ( model, React.none )


onToogleExpand : MainTab -> ID -> Model -> UpdateResponse msg
onToogleExpand tab itemId model =
    let
        model_ =
            toggleExpand itemId tab model
    in
        ( model_, React.none )


onEnterEditing : Config msg -> MainTab -> ID -> Model -> UpdateResponse msg
onEnterEditing config tab itemId model =
    let
        model_ =
            enterEditing itemId tab config.database model
    in
        ( model_, React.none )


onLeaveEditing : MainTab -> ID -> Model -> UpdateResponse msg
onLeaveEditing tab itemId model =
    let
        model_ =
            leaveEditing itemId tab model
    in
        ( model_, React.none )


onUpdateTextFilter : Config msg -> MainTab -> String -> Model -> UpdateResponse msg
onUpdateTextFilter config tab filter model =
    let
        model_ =
            updateTextFilter filter tab config.database model
    in
        ( model_, React.none )


onGoTab : MainTab -> Model -> UpdateResponse msg
onGoTab tab model =
    let
        model_ =
            { model | selected = tab }
    in
        ( model_, React.none )
