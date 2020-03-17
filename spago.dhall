{ sources =
    [ "src/**/*.purs", "test/**/*.purs" ]
, name =
    "purescript-firestore"
, dependencies =
    [ "aff-promise"
    , "argonaut"
    , "bytestrings"
    , "dotenv"
    , "effect"
    , "exceptions"
    , "foldable-traversable"
    , "foreign-object"
    , "functions"
    , "maybe"
    , "node-process"
    , "nullable"
    , "precise-datetime"
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
