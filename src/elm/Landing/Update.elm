module Landing.Update exposing (update)

import Update.Extra as Update
import Core.Messages exposing (CoreMsg)
import Core.Models exposing (CoreModel)
import Landing.Messages exposing (LandMsg(..))
import Landing.Models exposing (LandModel)
import Landing.SignUp.Update
import Landing.Login.Update


update : LandMsg -> LandModel -> CoreModel -> ( LandModel, Cmd LandMsg, List CoreMsg )
update msg model core =
    case msg of
        MsgSignUp subMsg ->
            let
                ( signUp_, cmd, coreMsg ) =
                    Landing.SignUp.Update.update subMsg model.signUp core
            in
                ( { model | signUp = signUp_ }, Cmd.map MsgSignUp cmd, coreMsg )

        MsgLogin subMsg ->
            let
                ( login_, cmd, coreMsg ) =
                    Landing.Login.Update.update subMsg model.login core
            in
                ( { model | login = login_ }, Cmd.map MsgLogin cmd, coreMsg )
