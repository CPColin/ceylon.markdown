import ceylon.markdown.parser {
    Node,
    NodeType,
    SourceLoc,
    SourcePos
}
import ceylon.markdown.renderer {
    RenderOptions
}
import ceylon.test {
    parameters,
    test
}

// These tests are still a bit naive and probably need some refactoring to make them more robust and
// test more situations.

{[Integer, String, String]*} testLinkHeadingsOptionParameters = {
    [1, "Test Heading", "test_heading"],
    [2, "Test Heading", "test_heading"],
    [3, "Test Heading", "test_heading"],
    [4, "Test Heading", "test_heading"],
    [5, "Test Heading", "test_heading"],
    [6, "Test Heading", "test_heading"]
};

{Boolean*} testSafeOptionDestinationParameters = { false, true };

{String*} testSoftBreakOptionParameters = {
    "ZZZ"
};

{[NodeType, Integer, Integer, Integer, Integer]*} testSourcePosOptionParameters = {
    // The commented-out values were not implemented in commonmark.js, so they weren't implemented
    // here, either. If this changes in the future, we can uncomment those values.
    [NodeType.blockQuote, 1, 2, 3, 4],
    //[NodeType.code, 2, 3, 4, 5],
    [NodeType.codeBlock, 3, 4, 5, 6],
    //[NodeType.document, 4, 5, 6, 7],
    //[NodeType.emphasis, 5, 6, 7, 8],
    [NodeType.heading, 6, 7, 8, 9],
    //[NodeType.htmlBlock, 7, 8, 9, 10],
    //[NodeType.htmlInline, 8, 9, 10, 11],
    //[NodeType.image, 9, 10, 11, 12],
    [NodeType.item, 10, 11, 12, 13],
    //[NodeType.lineBreak, 11, 12, 13, 14],
    [NodeType.link, 12, 13, 14, 15],
    [NodeType.list, 13, 14, 15, 16],
    [NodeType.paragraph, 14, 15, 16, 17],
    //[NodeType.softBreak, 15, 16, 17, 18],
    //[NodeType.strong, 16, 17, 18, 19],
    //[NodeType.text, 20, 21, 22, 23],
    [NodeType.thematicBreak, 21, 22, 23, 24]
};

shared abstract class RendererTests() {
    "This is very similar to [[testLanguageAttribute]], even going so far as to use the same test
     parameters. Both tests essentially test the same thing, except this one has the extra layer of
     making sure the renderer is playing along."
    test
    parameters (`value testLanguageAttributeParameters`)
    shared void testLanguageAttribute(String? defaultLanguage, String? explicitLanguage,
        String? expectedLanguage) {
        value options = RenderOptions {
            defaultLanguage = defaultLanguage;
        };
        value node = codeBlock(explicitLanguage);
        value expectedAttribute = expectedLanguageAttribute(expectedLanguage);
        
        verifyLanguageAttribute(options, node, expectedAttribute);
    }
    
    test
    parameters (`value testLinkHeadingsOptionParameters`)
    shared void testLinkHeadingsOption(Integer level, String headingText, String expectedId) {
        value options = RenderOptions {
            linkHeadings = true;
        };
        value node = Node(NodeType.heading);
        
        node.level = level;
        
        value text = Node(NodeType.text);
        
        text.literal = headingText;
        
        node.appendChild(text);
        
        verifyLinkHeadingsOption(options, node);
    }
    
    test
    parameters (`value testSafeOptionDestinationParameters`)
    shared void testSafeOptionDestination(Boolean image) {
        value options = RenderOptions {
            safe = true;
        };
        value node = Node(image then NodeType.image else NodeType.link);
        
        node.destination = "javascript:void";
        
        verifySafeOptionDestination(options, node, image);
    }
    
    test
    shared void testSafeOptionRawHtml() {
        value options = RenderOptions {
            safe = true;
        };
        value node = Node(NodeType.htmlInline);
        
        node.literal = "<html>";
        
        verifySafeOptionRawHtml(options, node);
    }
    
    test
    parameters (`value testSoftBreakOptionParameters`)
    shared void testSoftBreakOption(String softBreak) {
        value options = RenderOptions {
            softBreak = softBreak;
        };
        value node = Node(NodeType.softBreak);
        
        verifySoftBreakOption(options, node, softBreak);
    }
    
    test
    parameters (`value testSourcePosOptionParameters`)
    shared void testSourcePosOption(NodeType nodeType, Integer startLine, Integer startColumn,
        Integer endLine, Integer endColumn) {
        value options = RenderOptions {
            sourcePos = true;
        };
        value node = Node(nodeType,
            SourcePos(SourceLoc(startLine, startColumn), SourceLoc(endLine, endColumn)));
        
        node.level = 1;
        
        verifySourcePosOption(options, node, startLine, startColumn, endLine, endColumn);
    }
    
    test
    shared void testSpecialLink() {
        value text = "text";
        value node = Node(NodeType.specialLink);
        
        node.literal = text;
        
        verifySpecialLink(node);
    }
    
    shared formal void verifyLanguageAttribute(RenderOptions options, Node node,
        String? expectedAttribute);
    
    shared formal void verifyLinkHeadingsOption(RenderOptions options, Node node);
    
    shared formal void verifySafeOptionDestination(RenderOptions options, Node node, Boolean image);
    
    shared formal void verifySafeOptionRawHtml(RenderOptions options, Node node);
    
    shared formal void verifySoftBreakOption(RenderOptions options, Node node, String softBreak);
    
    shared formal void verifySourcePosOption(RenderOptions options, Node node, Integer startLine,
        Integer startColumn, Integer endLine, Integer endColumn);
    
    shared formal void verifySpecialLink(Node node);
}
