module Game.Web.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Events as Events
import Utils.Update as Update
import Game.Models as Game
import Game.Web.Models exposing (..)
import Game.Web.Messages exposing (..)
import Game.Web.Types exposing (..)
import Game.Web.Requests exposing (..)
import Game.Web.Requests.DNS as DNS


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Load url ->
            onLoad game url model

        Refresh url ->
            onRefresh game url model

        Request data ->
            onRequest game (receive data) model

        Event data ->
            updateEvent game data model



-- internals


onLoad : Game.Model -> String -> Model -> UpdateResponse
onLoad game url model =
    let
        site =
            get url model
    in
        case site.type_ of
            Unknown ->
                let
                    cmd =
                        DNS.request url game
                in
                    ( model, cmd, Dispatch.none )

            _ ->
                ( model, Cmd.none, Dispatch.none )


onRefresh : Game.Model -> String -> Model -> UpdateResponse
onRefresh game url model =
    let
        model_ =
            remove url model

        cmd =
            DNS.request url game
    in
        ( model_, cmd, Dispatch.none )


onRequest : Game.Model -> Maybe Response -> Model -> UpdateResponse
onRequest game response model =
    case response of
        Just response ->
            updateRequest game response model

        Nothing ->
            Update.fromModel model


updateRequest : Game.Model -> Response -> Model -> UpdateResponse
updateRequest game response model =
    case response of
        DNS response ->
            onDNS game response model


updateEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
updateEvent game event model =
    Update.fromModel model


onDNS : Game.Model -> DNS.Response -> Model -> UpdateResponse
onDNS game response model =
    case response of
        DNS.Okay site ->
            let
                model_ =
                    refresh site.url site model
            in
                ( model_, Cmd.none, Dispatch.none )
