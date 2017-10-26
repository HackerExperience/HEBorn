module Game.Helper exposing (..)

-- DATA AS SOURCE


getEndpoints : Data -> List Servers.CId
getEndpoints =
    (.server)
        >> Servers.getEndpoints
        >> Maybe.withDefault []



-- GAME AS SOURCE


fromGateway : Model -> Maybe Data
fromGateway model =
    model
        |> getGateway


fromEndpoint : Model -> Maybe Data
fromEndpoint model =
    model
        |> getEndpoint
        |> Maybe.map (fromServer True model)


fromServerCId : Servers.CId -> Model -> Maybe Data
fromServerCId cid model =
    let
        servers =
            getServers model

        ( gatewayId, gateway ) =
            model
                |> getGateway
                |> Maybe.map (\( left, right ) -> ( Just left, Just right ))
                |> Maybe.withDefault ( Nothing, Nothing )

        endpointId =
            Maybe.andThen Servers.getEndpointCId gateway

        maybeCid =
            Just cid

        online =
            maybeCid == gatewayId || maybeCid == endpointId
    in
        case Servers.get cid servers of
            Just server ->
                Just <| fromServer online model ( cid, server )

            Nothing ->
                Nothing
