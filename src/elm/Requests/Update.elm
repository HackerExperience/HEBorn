module Requests.Update exposing (getRequestData
                                , makeRequest, queueRequest
                                , removeRequestId)


import Uuid
import Random.Pcg exposing (step)
import Dict

import Requests.Models exposing ( Model, RequestID
                                , Request(RequestInvalid, NewRequest)
                                , RequestStoreData, RequestPayload
                                , Response(..)
                                , NewRequestData
                                , ResponseDecoder, noopDecoder
                                , storeRequest
                                , encodeRequest)
import WS.WS
import Utils
import Core.Components exposing (Component(ComponentInvalid))
import Core.Models as Core


{-| getRequestData will fetch the RequestStore and return the RequestStoreData
(the 3-tuple (Component, Request, Decoder)) if the `request_id` key is found
on the dict. If the request key is not found, returns an RequestStoreData with
invalid data. -}
getRequestData : Model -> RequestID -> RequestStoreData
getRequestData model request_id =
    case Dict.get request_id model.requests of

        Just (request, payload, decoder) ->
            (request, payload, decoder)

        Nothing ->
            (ComponentInvalid, RequestInvalid, noopDecoder)


{-| removeRequestId will remove the entry identified by key `request_id` on the
RequestStore-}
removeRequestId : Model -> RequestID -> Model
removeRequestId model request_id =
    let
        requests_ = Dict.remove request_id model.requests
    in
        {model | requests = requests_}


{-| makeRequest is the function to actually send a message (internally Elm
won't send it right away, but that's an implementation detail).

makeRequest expects three important things: model, requestData and component.
`model` is needed because it contains UUID information (seed, etc). `component`
allow us to identify which component is sending this request (useful when the
response comes from the server) and requestData contains the request data:
its type (one of `Requests.Models.Request`), payload (one of
`Requests.Models.RequestPayload`) and decoder (which tell us how the server
response should be handled)

Before sending the message, a `RequestStore` is created, which contains data we
need to correctly route the response to the component (the 3-tuple
`(Component, Request, Decoder)`. The RequestStore is identified by the request UUID,
which the server will sent with the response (on the key "request_id").-}
makeRequest : Core.Model -> NewRequestData -> Component -> (Core.Model, Cmd msg)
makeRequest core requestData component =
    let
        model = core.requests
        (request, payload, response) = requestData
        payload_ = encodeRequest {payload | request_id = model.uuid}
        requests_ = storeRequest model model.uuid component request response
        (uuid_, seed_) = step Uuid.uuidGenerator model.seed
        model_ =
            { requests = requests_
            , seed = seed_
            , uuid = Uuid.toString uuid_
            }
    in
        ({core | requests = model_}, WS.WS.send payload_)


{-| queueRequest is the function a module should call to let Elm know we want
to make a request. It's stateless since it will only emit an internal elm
message. The actual request will be sent once makeRequest is called.
This function expects a Request containing a NewRequest inside it. Since each
component has its own Request type, we cant create a single type hinting that
matches everyone, hence the `a -> Cmd a`. -}
queueRequest : a -> Cmd a
queueRequest request =
    Utils.msgToCmd request

