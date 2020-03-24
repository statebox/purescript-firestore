{ sources =
    [ "src/**/*.purs", "test/**/*.purs" ]
, name =
    "purescript-firestore"
, dependencies =
    [ "aff-promise"
    , "argonaut"
    , "arrays"
    , "dotenv"
    , "effect"
    , "exceptions"
    , "foldable-traversable"
    , "foreign-object"
    , "functions"
    , "maybe"
    , "newtype"
    , "node-process"
    , "nullable"
    , "profunctor"
    , "psci-support"
    , "quickcheck"
    , "spec"
    , "spec-quickcheck"
    , "strings"
    , "transformers"
    ]
, packages =
    ./packages.dhall
}
