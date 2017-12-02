import ceylon.markdown.parser {
    Document,
    Node,
    NodeWalker
}
import ceylon.test {
    assertEquals,
    fail
}

void compareAsts(Document ceylonMarkdownDocument, INode commonmarkJsDocument) {
    debugTree(ceylonMarkdownDocument);
    debugTree(commonmarkJsDocument);
    
    value ceylonMarkdownIterator = ceylonMarkdownDocument.iterator();
    value commonmarkJsWalker = NodeWalker(commonmarkJsDocument);
    
    while (true) {
        value ceylonMarkdownEvent = ceylonMarkdownIterator.next();
        value commonmarkJsEvent = commonmarkJsWalker.next();
        
        if (is Finished ceylonMarkdownEvent) {
            if (!is Finished commonmarkJsEvent) {
                fail("ceylon.markdown node does not exist, but commonmark.js node does
                      ``debugNode(commonmarkJsEvent[1])``");
            }
            
            return;
        } else if (is Finished commonmarkJsEvent) {
            fail("ceylon.markdown node exists, but commonmark.js node does not
                  ``debugNode(ceylonMarkdownEvent[1])``");
        } else {
            value compare
                = compareDirectPortAttributes(ceylonMarkdownEvent[1], commonmarkJsEvent[1]);
            
            compare("type", Node.type, INode.type);
            
            compare("destination", Node.destination, INode.destination);
            compare("info", Node.info, INode.info);
            compare("level", Node.level, INode.level);
            compare("listDelimiter", Node.listDelimiter, INode.listDelimiter);
            compare("listStart", Node.listStart, INode.listStart);
            compare("listTight", Node.listTight, INode.listTight);
            compare("listType", Node.listType, INode.listType);
            compare("literal", Node.literal, INode.literal);
            compare("title", Node.title, INode.title);
        }
    }
}

void compareDirectPortAttributes<Type>(Node ceylonMarkdownNode, INode commonmarkJsNode)
        (String attributeName, Type(Node) ceylonMarkdownAttribute,
        Type(INode) commonmarkJsAttribute) {
    try {
        assertEquals(ceylonMarkdownAttribute(ceylonMarkdownNode),
            commonmarkJsAttribute(commonmarkJsNode),
            "Mismatched ``attributeName`` attributes");
    } catch (AssertionError e) {
        print("``debugNode(ceylonMarkdownNode)``
               ``debugNode(commonmarkJsNode)``");
        
        throw e;
    }
}
