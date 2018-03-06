module Utils.Model.RandomUuid exposing (Uuid, getSeed, newUuid, setSeed, generator)

import Random.Pcg as Random
import Uuid


type alias Model r =
    { r | randomUuidSeed : Random.Seed }


type alias Uuid =
    String


getSeed :
    Model r
    -> Random.Seed
getSeed { randomUuidSeed } =
    randomUuidSeed


newUuid :
    Model r
    -> ( Model r, Uuid )
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


setSeed : Int -> Model r -> Model r
setSeed int model =
    { model | randomUuidSeed = Random.initialSeed int }


generator : Random.Generator Int
generator =
    Random.int 0 Random.maxInt
