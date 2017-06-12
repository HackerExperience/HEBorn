module OS.SessionManager.WindowManager.Context exposing (Context(..), toString)


type Context
    = GatewayContext
    | EndpointContext
    | NoContext


toString : Context -> String
toString context =
    case context of
        GatewayContext ->
            "Gateway"

        EndpointContext ->
            "Endpoint"

        NoContext ->
            ""
