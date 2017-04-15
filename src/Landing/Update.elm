module Landing.Update exposing (update)

import Requests.Models exposing (Request(NewRequest), NewRequestData)
import Core.Components exposing (Component(..))
import Core.Messages exposing (CoreMsg(MsgLand))
import Core.Models exposing (CoreModel)
import Landing.Messages exposing (LandMsg(..))
import Landing.Models exposing (LandModel)
import Landing.SignUp.Update
import Landing.SignUp.Messages
import Landing.Login.Update
import Landing.Login.Messages


update : LandMsg -> LandModel -> CoreModel -> ( LandModel, Cmd LandMsg, List CoreMsg )
update msg model core =
    case msg of
        MsgSignUp (Landing.SignUp.Messages.Request (NewRequest requestData)) ->
            ( model, Cmd.none, delegateRequest requestData ComponentSignUp )

        MsgSignUp subMsg ->
            let
                ( signUp_, cmd, coreMsg ) =
                    Landing.SignUp.Update.update subMsg model.signUp core
            in
                ( { model | signUp = signUp_ }, Cmd.map MsgSignUp cmd, coreMsg )

        MsgLogin (Landing.Login.Messages.Request (NewRequest requestData)) ->
            ( model, Cmd.none, delegateRequest requestData ComponentLogin )

        MsgLogin subMsg ->
            let
                ( login_, cmd, coreMsg ) =
                    Landing.Login.Update.update subMsg model.login core
            in
                ( { model | login = login_ }, Cmd.map MsgLogin cmd, coreMsg )

        Event _ ->
            ( model, Cmd.none, [] )

        Request _ _ ->
            ( model, Cmd.none, [] )

        Response _ _ ->
            ( model, Cmd.none, [] )

        NoOp ->
            ( model, Cmd.none, [] )


delegateRequest : NewRequestData -> Component -> List CoreMsg
delegateRequest requestData component =
    [ MsgLand (Request (NewRequest requestData) component) ]
