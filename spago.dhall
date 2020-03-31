{ sources =
    [ "src/**/*.purs", "test/**/*.purs" ]
, name =
    "purescript-firestore"
, dependencies =
    [ "aff"
    , "aff-promise"
    , "argonaut"
    , "arrays"
    , "dotenv"
    , "effect"
    , "exceptions"
    , "foldable-traversable"
    , "foreign-object"
    , "functions"
    , "maybe"
    , "node-process"
    , "nullable"
    , "profunctor"
    , "psci-support"
    , "quickcheck"
    , "refs"
    , "spec"
    , "spec-quickcheck"
    , "strings"
    , "transformers"
    ]
, packages =
    ./packages.dhall
}
