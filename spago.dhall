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
    , "foldable-traversable"
    , "foreign-object"
    , "functions"
    , "maybe"
    , "node-process"
    , "nullable"
    , "precise-datetime"
    , "psci-support"
    , "spec"
    , "strings"
    ]
, packages =
    ./packages.dhall
}
