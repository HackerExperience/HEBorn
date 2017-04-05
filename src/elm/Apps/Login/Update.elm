module Apps.Login.Update exposing (..)


import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg)
import Apps.Login.Models exposing (Model)
import Apps.Login.Messages exposing (Msg(..))
import Apps.Login.Requests exposing (responseHandler
                                    , requestLogin
                                    -- , requestUsernameExists
                                    )


update : Msg -> Model -> GameModel -> (Model, Cmd Msg, List GameMsg)
update msg model core =
    case msg of

        SubmitLogin ->
            let
                cmd = requestLogin model.username model.password
            in
                (model, cmd, [])

        SetUsername username ->
            ({model | username = username}, Cmd.none, [])

        ValidateUsername ->
            (model, Cmd.none, [])

        SetPassword password ->
            ({model | password = password}, Cmd.none, [])

        ValidatePassword ->
            (model, Cmd.none, [])

        Event event ->
            (model, Cmd.none, [])

        Request _ ->
            (model, Cmd.none, [])

        Response request data ->
            responseHandler request data model core


