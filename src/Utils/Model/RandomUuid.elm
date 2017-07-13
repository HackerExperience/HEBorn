module Utils.Model.RandomUuid exposing (Model, Uuid, getSeed, newUuid)

import Random.Pcg as Random
import Uuid


type alias Model ext =
    { ext | randomUuidSeed : Random.Seed }


type alias Uuid =
    String


getSeed : Model a -> Random.Seed
getSeed { randomUuidSeed } =
    randomUuidSeed


newUuid : Model a -> ( Model a, Uuid )
newUuid ({ randomUuidSeed } as model) =
    let
        ( uuid, randomUuidSeed_ ) =
            Random.step Uuid.uuidGenerator randomUuidSeed

        uuid_ =
            Uuid.toString uuid

        model_ =
            { model | randomUuidSeed = randomUuidSeed_ }
    in
        ( model_, uuid_ )
