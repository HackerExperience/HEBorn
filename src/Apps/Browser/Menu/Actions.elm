module Apps.Browser.Menu.Actions exposing (actionHandler)

import Utils.React as React exposing (React)
import Apps.Browser.Models exposing (..)
import Apps.Browser.Menu.Config exposing (..)
import Apps.Browser.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Config msg
    -> MenuAction
    -> Model
    -> ( Model, React msg )
actionHandler config action model =
    case action of
        NewTab ->
            let
                model_ =
                    addTab model
            in
                ( model_, React.none )

        DeleteTab n ->
            let
                model_ =
                    deleteTab n model
            in
                ( model_, React.none )

        GoPrevious ->
            let
                tab_ =
                    gotoPreviousPage <| getNowTab model

                model_ =
                    setNowTab tab_ model
            in
                ( model_, React.none )

        GoNext ->
            let
                tab_ =
                    gotoNextPage <| getNowTab model

                model_ =
                    setNowTab tab_ model
            in
                ( model_, React.none )

        GoHome ->
            let
                app =
                    getNowTab model

                tab_ =
                    gotoPage "about:blank" BlankModel app

                model_ =
                    setNowTab tab_ model
            in
                ( model_, React.none )
