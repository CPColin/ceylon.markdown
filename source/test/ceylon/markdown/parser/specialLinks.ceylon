import ceylon.markdown.parser {
    Node,
    NodeType,
    ParseOptions,
    Parser,
    transformSpecialLinks
}
import ceylon.test {
    assertEquals,
    assertFalse,
    assertTrue,
    test
}

{Boolean*} testSpecialLinksOptionParameters = {
    false,
    true
};

String specialLinkNodeText = "link";

String specialLinkNodeInput = "[[``specialLinkNodeText``]]";

String collectNodeText(Node root) {
    value text = StringBuilder();
    
    for ([entering, node] in root) {
        if (node.nodeType == NodeType.text, exists literal = node.literal) {
            text.append(literal);
        }
    }
    
    return text.string;
}

Node createSpecialLinkNode(Boolean specialLinksOption) {
    value options = ParseOptions {
        specialLinks = specialLinksOption;
    };
    value parser = Parser(options);
    value root = parser.parse(specialLinkNodeInput);
    value paragraph = root.lastChild;
    
    assertTrue(paragraph exists);
    
    assert (exists paragraph);
    
    assertEquals(paragraph.nodeType, NodeType.paragraph);
    
    value firstChild = paragraph.firstChild;
    
    assertTrue(firstChild exists);
    
    assert (exists firstChild);
    
    return paragraph;
}

test
shared void testSpecialLinksOptionDisabled() {
    value paragraph = createSpecialLinkNode(false);
    
    assertEquals(collectNodeText(paragraph), specialLinkNodeInput);
}

test
shared void testSpecialLinksOptionEnabled() {
    value paragraph = createSpecialLinkNode(true);
    value specialLink = paragraph.firstChild;
    
    assertTrue(specialLink exists);
    
    assert (exists specialLink);
    
    assertEquals(specialLink.nodeType, NodeType.specialLink);
    
    assertEquals(specialLink.literal, specialLinkNodeText);
}

test
shared void testTransformSpecialLinks() {
    value nodeType = NodeType.thematicBreak;
    function transform(String _) => Node(nodeType);
    value paragraph = createSpecialLinkNode(true);
    
    transformSpecialLinks(paragraph, transform);
    
    value child = paragraph.firstChild;
    
    assertTrue(child exists);
    
    assert (exists child);
    
    assertEquals(child.nodeType, nodeType);
    
    assertFalse(child.next exists);
}
