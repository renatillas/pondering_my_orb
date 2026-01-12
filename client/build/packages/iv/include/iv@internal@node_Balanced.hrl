-record(balanced, {
    size :: integer(),
    children :: iv@internal@vector:vector(iv@internal@node:node_(any()))
}).
