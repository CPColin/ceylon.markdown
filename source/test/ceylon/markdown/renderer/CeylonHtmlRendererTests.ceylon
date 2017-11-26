import ceylon.html {
    A,
    Code,
    H1,
    H2,
    H3,
    H4,
    H5,
    H6,
    Img,
    Node,
    Pre
}
import ceylon.markdown.parser {
    AstNode=Node,
    Document
}
import ceylon.markdown.renderer {
    CeylonHtmlRenderer,
    RenderOptions
}
import ceylon.test {
    assertEquals,
    assertTrue,
    fail
}

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
    
    void verifyAttribute(Node node, String attributeName, String? expectedValue) {
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
        assertTrue(element is Type);
        
        assert (is Type element);
        
        return element;
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
}
