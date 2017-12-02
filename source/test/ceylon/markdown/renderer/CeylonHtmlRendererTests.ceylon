import ceylon.html {
    A,
    Blockquote,
    Br,
    Code,
    Em,
    H1,
    H2,
    H3,
    H4,
    H5,
    H6,
    Hr,
    Img,
    Li,
    Node,
    Ol,
    P,
    Pre,
    Raw,
    Strong,
    Ul
}
import ceylon.language.meta.declaration {
    ClassDeclaration
}
import ceylon.markdown.parser {
    AstNode=Node,
    Document,
    ListData,
    NodeType
}
import ceylon.markdown.renderer {
    CeylonHtmlRenderer,
    RenderOptions
}
import ceylon.test {
    assertEquals,
    assertTrue,
    fail,
    parameters,
    test
}
import ceylon.language.meta {
    type,
    typeLiteral
}

{[Integer, ClassDeclaration]*} testHeadingParameters = {
    [1, `class H1`],
    [2, `class H2`],
    [3, `class H3`],
    [4, `class H4`],
    [5, `class H5`],
    [6, `class H6`]
};

{String*} testHtmlParameters = {
    "",
    "<b>",
    "<!-- test -->"
};

{[String, String?, String, String?, String?]*} testImageParameters = {
    ["#", null, "", null, null],
    ["#", null, "", "", null],
    ["#", null, "", "abc", "abc"],
    ["#", "description", "description", "", null],
    ["#", "description", "description", "abc", "abc"]
};

{[String, String?, String?, String]*} testLinkParameters = {
    ["#", null, null, ""],
    ["#", "", null, ""],
    ["#", "abc", "abc", ""],
    ["#", null, null, "link text"],
    ["#", "abc", "abc", "link text"]
};

{[String, Integer?, Integer?, ClassDeclaration]*} testListParameters = {
    ["bullet", null, null, `class Ul`],
    ["bullet", 0, null, `class Ul`],
    ["bullet", 1, null, `class Ul`],
    ["bullet", 2, null, `class Ul`],
    ["ordered", null, null, `class Ol`],
    ["ordered", 0, 0, `class Ol`],
    ["ordered", 1, null, `class Ol`],
    ["ordered", 2, 2, `class Ol`]
};

{String*} testSoftBreakParameters = {
    "",
    "<b>",
    "\n",
    "ZZZ"
};

{[String?, String?]*} testTextParameters = {
    [null, ""],
    ["", ""],
    ["test", "test"]
};

shared class CeylonHtmlRendererTests() extends RendererTests() {
    function renderNode(RenderOptions options, AstNode node) {
        value document = Document();
        
        document.appendChild(node);
        
        value renderer = CeylonHtmlRenderer(options);
        
        return renderer.render(document);
    }
    
    function renderText(CeylonHtmlRenderer.Element[] elements) {
        value stringBuilder = StringBuilder();
        
        elements.coalesced.each((element) => stringBuilder.append(element.string));
        
        return stringBuilder.string;
    }
    
    void verifyAttribute(Node node, String attributeName, Anything expectedValue) {
        for (attribute in node.attributes) {
            if (exists attribute) {
                value name->val = attribute;
                
                if (name == attributeName) {
                    assertEquals(val, expectedValue);
                    
                    return;
                }
            }
        }
        
        if (exists expectedValue) {
            fail("Attribute not found");
        }
    }
    
    function verifyElement<Type>(Anything element) {
        assertTrue(element is Type, "Expected ``typeLiteral<Type>()`` but was ``type(element)``");
        
        assert (is Type element);
        
        return element;
    }
    
    test
    shared void testBlockQuote() {
        value node = AstNode(NodeType.blockQuote);
        value output = renderNode(RenderOptions(), node);
        
        verifyElement<Blockquote>(output.first);
    }
    
    test
    shared void testCode() {
        value node = AstNode(NodeType.code);
        value output = renderNode(RenderOptions(), node);
        
        verifyElement<Code>(output.first);
    }
    
    test
    shared void testCodeBlock() {
        value node = AstNode(NodeType.codeBlock);
        value output = renderNode(RenderOptions(), node);
        value pre = verifyElement<Pre>(output.first);
        
        verifyElement<Code>(pre.children.first);
    }
    
    test
    shared void testEmphasis() {
        value node = AstNode(NodeType.emphasis);
        value output = renderNode(RenderOptions(), node);
        
        verifyElement<Em>(output.first);
    }
    
    test
    parameters (`value testHeadingParameters`)
    shared void testHeading(Integer level, ClassDeclaration type) {
        value node = AstNode(NodeType.heading);
        
        node.level = level;
        
        value output = renderNode(RenderOptions(), node);
        
        assertTrue(type.apply<>().typeOf(output.first));
    }
    
    test
    parameters(`value testHtmlParameters`)
    shared void testHtmlBlock(String html) {
        value node = AstNode(NodeType.htmlBlock);
        
        node.literal = html;
        
        value output = renderNode(RenderOptions(), node);
        value start = verifyElement<String>(output[0]);
        value raw = verifyElement<Raw>(output[1]);
        value end = verifyElement<String>(output[2]);
        
        assertEquals(start, "\n");
        assertEquals(raw.data, html);
        assertEquals(end, "\n");
    }
    
    test
    parameters(`value testHtmlParameters`)
    shared void testHtmlInline(String html) {
        value node = AstNode(NodeType.htmlInline);
        
        node.literal = html;
        
        value output = renderNode(RenderOptions(), node);
        value raw = verifyElement<Raw>(output.first);
        
        assertEquals(raw.data, html);
    }
    
    test
    parameters(`value testImageParameters`)
    shared void testImage(String destination, String? alt, String expectedAlt, String? title,
        String? expectedTitle) {
        value node = AstNode(NodeType.image);
        value child = AstNode(NodeType.text);
        
        child.literal = alt;
        
        node.destination = destination;
        node.appendChild(child);
        node.title = title;
        
        value output = renderNode(RenderOptions(), node);
        value image = verifyElement<Img>(output.first);
        
        verifyAttribute(image, "src", destination);
        verifyAttribute(image, "alt", expectedAlt);
        verifyAttribute(image, "title", expectedTitle);
    }
    
    test
    shared void testItem() {
        value node = AstNode(NodeType.item);
        value output = renderNode(RenderOptions(), node);
        
        verifyElement<Li>(output.first);
    }
    
    test
    shared void testLineBreak() {
        value node = AstNode(NodeType.lineBreak);
        value output = renderNode(RenderOptions(), node);
        
        verifyElement<Br>(output.first);
    }
    
    test
    parameters(`value testLinkParameters`)
    shared void testLink(String destination, String? title, String? expectedTitle,
        String linkText) {
        value node = AstNode(NodeType.link);
        value child = AstNode(NodeType.text);
        
        child.literal = linkText;
        
        node.destination = destination;
        node.appendChild(child);
        node.title = title;
        
        value output = renderNode(RenderOptions(), node);
        value anchor = verifyElement<A>(output.first);
        value anchorText = verifyElement<String>(anchor.children.first);
        
        verifyAttribute(anchor, "href", destination);
        verifyAttribute(anchor, "title", expectedTitle);
        assertEquals(anchorText, linkText);
    }
    
    test
    parameters(`value testListParameters`)
    shared void testList(String listType, Integer? start, Integer? expectedStart,
        ClassDeclaration elementType) {
        value node = AstNode(NodeType.list);
        value listData = ListData {
            start = start;
            type = listType;
        };
        
        node.listData = listData;
        
        value output = renderNode(RenderOptions(), node);
        value list = verifyElement<Ol|Ul>(output.first);
        
        assertTrue(elementType.apply<>().typeOf(list));
        verifyAttribute(list, "start", expectedStart);
    }
    
    
    test
    parameters(`value testElideInTightListParameters`)
    shared void testListTight(Boolean? tight) {
        value list = createTestList(tight);
        value output = renderNode(RenderOptions(), list);
        value ol = verifyElement<Ol>(output.first);
        value li = verifyElement<Li>(ol.children.first);
        
        if (exists tight, tight) {
            verifyElement<String>(li.children.first);
        } else {
            verifyElement<P>(li.children.first);
        }
    }
    
    test
    shared void testParagraph() {
        value node = AstNode(NodeType.paragraph);
        value output = renderNode(RenderOptions(), node);
        
        verifyElement<P>(output.first);
    }
    
    test
    parameters(`value testSoftBreakParameters`)
    shared void testSoftBreak(String softBreak) {
        value options = RenderOptions {
            softBreak = softBreak;
        };
        value node = AstNode(NodeType.softBreak);
        value output = renderNode(options, node);
        value raw = verifyElement<Raw>(output.first);
        
        assertEquals(raw.data, softBreak);
    }
    
    test
    shared void testStrong() {
        value node = AstNode(NodeType.strong);
        value output = renderNode(RenderOptions(), node);
        
        verifyElement<Strong>(output.first);
    }
    
    test
    parameters(`value testTextParameters`)
    shared void testText(String? literal, String? expected) {
        value node = AstNode(NodeType.text);
        
        node.literal = literal;
        
        value output = renderNode(RenderOptions(), node);
        value actual = verifyElement<String>(output.first);
        
        assertEquals(actual, expected);
    }
    
    test
    shared void testThematicBreak() {
        value node = AstNode(NodeType.thematicBreak);
        value output = renderNode(RenderOptions(), node);
        
        verifyElement<Hr>(output.first);
    }
    
    shared actual void verifyLanguageAttribute(RenderOptions options, AstNode node,
        String? expectedAttribute) {
        value output = renderNode(options, node);
        value pre = verifyElement<Pre>(output.first);
        value code = verifyElement<Code>(pre.children.first);
        
        verifyAttribute(code, "class", expectedAttribute);
    }
    
    shared actual void verifyLinkHeadingsOption(RenderOptions options, AstNode node) {
        value output = renderNode(options, node);
        // We don't care which heading level we have here; that'll be verified elsewhere.
        value heading = verifyElement<H1|H2|H3|H4|H5|H6>(output.first);
        
        verifyAttribute(heading, "id", "test_heading");
        
        value anchor = verifyElement<A>(heading.children.first);
        
        verifyAttribute(anchor, "href", "#test_heading");
    }
    
    shared actual void verifySafeOptionDestination(RenderOptions options, AstNode node,
        Boolean image) {
        value output = renderNode(options, node);
        
        if (image) {
            value img = verifyElement<Img>(output.first);
            
            verifyAttribute(img, "src", "");
        } else {
            value anchor = verifyElement<A>(output.first);
            
            verifyAttribute(anchor, "href", "");
        }
    }
    
    shared actual void verifySafeOptionRawHtml(RenderOptions options, AstNode node) {
        value output = renderNode(options, node);
        value content = renderText(output);
        
        assertEquals(content,
            "<!-- raw HTML omitted -->");
    }
    
    shared actual void verifySoftBreakOption(RenderOptions options, AstNode node,
        String softBreak) {
        value output = renderNode(options, node);
        value content = renderText(output);
        
        assertEquals(content, softBreak);
    }
    
    shared actual void verifySourcePosOption(RenderOptions options, AstNode node, Integer startLine,
        Integer startColumn, Integer endLine, Integer endColumn) {
        value output = renderNode(options, node);
        value element = verifyElement<Node>(output.first);
        value child = element.children.first;
        Node target;
        
        if (is Pre element, is Code child) {
            // Special case to unwrap <pre><code> blocks
            target = child;
        } else {
            target = element;
        }
        
        verifyAttribute(target, "data-sourcepos",
            "``startLine``:``startColumn``-``endLine``:``endColumn``");
    }
    
    shared actual void verifySpecialLink(AstNode node) {
        value output = renderNode(RenderOptions(), node);
        value element = verifyElement<String>(output.first);
        
        assertEquals(element, "[[``node.literal else ""``]]");
    }
}
