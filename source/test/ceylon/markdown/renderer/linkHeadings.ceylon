import ceylon.markdown.parser {
    Node,
    NodeType
}
import ceylon.markdown.renderer {
    RenderOptions,
    headingIdAttribute
}
import ceylon.test {
    assertEquals,
    parameters,
    test
}

{[Boolean, String, String?]*} testHeadingIdAttributeParameters = {
    [false, "Test Heading", null],
    [true, "Test Heading", "test_heading"]
};

test
parameters (`value testHeadingIdAttributeParameters`)
shared void testHeadingIdAttribute(Boolean linkHeadings, String heading, String? expected) {
    value renderOptions = RenderOptions {
        linkHeadings = linkHeadings;
    };
    value node = Node(NodeType.heading);
    
    node.literal = heading;
    
    assertEquals(headingIdAttribute(renderOptions)(node), expected);
}
