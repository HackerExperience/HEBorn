module Apps.Context exposing (..)


type alias ContextApp instance =
    { gateway : Maybe instance
    , remote : Maybe instance
    , context : ActiveContext
    }


type ActiveContext
    = ContextGateway
    | ContextEndpoint


initialContext : instance -> ContextApp instance
initialContext initialApp =
    { gateway = Just initialApp
    , remote = Nothing
    , context = ContextGateway
    }


active : ContextApp instance -> ActiveContext
active instance =
    instance.context


state : ContextApp instance -> Maybe instance
state instance =
    case (active instance) of
        ContextGateway ->
            instance.gateway

        ContextEndpoint ->
            instance.remote


switch : ContextApp instance -> ContextApp instance
switch instance =
    let
        context_ =
            case (active instance) of
                ContextGateway ->
                    ContextEndpoint

                ContextEndpoint ->
                    ContextGateway
    in
        { instance | context = context_ }
