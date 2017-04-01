module Core.Update exposing (..)


import Utils
import Core.Models exposing (CoreModel
                            , setToken, getToken)
import Core.Messages exposing (CoreMsg(..))
import Core.Requests exposing ( responseHandler
                              , requestLogout)


update : CoreMsg -> CoreModel -> (CoreModel, Cmd CoreMsg)
update msg model =
    case msg of
        SetToken token ->
            let
                account_ = setToken model.account token
            in
                ({model | account = account_}, Cmd.none)

        Logout ->
            let
                cmd = requestLogout (Utils.maybeToString
                                         (getToken model.account))
                account_ = setToken model.account Nothing
            in
                ({model | account = account_}, cmd)

        Event _ ->
            (model, Cmd.none)

        Request _ ->
            (model, Cmd.none)

        Response request data ->
            responseHandler request data model
