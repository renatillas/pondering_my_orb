-record(builder, {
    nodes :: list(iv@internal@vector:vector(iv@internal@node:node_(any()))),
    items :: iv@internal@vector:vector(any()),
    push_node :: fun((list(iv@internal@vector:vector(iv@internal@node:node_(any()))), iv@internal@node:node_(any()), integer()) -> list(iv@internal@vector:vector(iv@internal@node:node_(any())))),
    push_item :: fun((iv@internal@vector:vector(any()), any()) -> iv@internal@vector:vector(any()))
}).
