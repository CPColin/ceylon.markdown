import ceylon.html {
    A,
    Code,
    H2,
    Node,
    P,
    Pre
}
import ceylon.markdown.parser {
    Parser
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
    function render(String input, RenderOptions options) {
        value parser = Parser();
        value root = parser.parse(input);
        value renderer = CeylonHtmlRenderer(options);
        
        return renderer.render(root);
    }
    
    function renderText(CeylonHtmlRenderer.Element[] elements) {
        value stringBuilder = StringBuilder();
        
        elements.coalesced.each((element) => stringBuilder.append(element.string));
        
        return stringBuilder.string;
    }
    
    void verifyAttribute(Node node, String attributeName, String expectedValue) {
        for (attribute in node.attributes) {
            if (exists attribute) {
                value name->val = attribute;
                
                if (name == attributeName) {
                    assertEquals(val, expectedValue);
                    
                    return;
                }
            }
        }
        
        fail("Attribute not found");
    }
    
    function verifyElement<Type>(Anything element) {
        assertTrue(element is Type);
        
        assert (is Type element);
        
        return element;
    }
    
    shared actual void verifyDefaultLanguageOption(String input, RenderOptions options) {
        value output = render(input, options);
        value pre = verifyElement<Pre>(output.first);
        value code = verifyElement<Code>(pre.children.first);
        
        verifyAttribute(code, "class", "language-test");
    }
    
    shared actual void verifyLinkHeadingsOption(String input, RenderOptions options) {
        value output = render(input, options);
        value heading = verifyElement<H2>(output.first);
        
        verifyAttribute(heading, "id", "test_heading");
        
        value anchor = verifyElement<A>(heading.children.first);
        
        verifyAttribute(anchor, "href", "#test_heading");
    }
    
    shared actual void verifySafeOptionLinkDestination(String input, RenderOptions options) {
        value output = render(input, options);
        value paragraph = verifyElement<P>(output.first);
        value anchor = verifyElement<A>(paragraph.children.first);
        
        verifyAttribute(anchor, "href", "");
    }
    
    shared actual void verifySafeOptionRawHtml(String input, RenderOptions options) {
        value output = render(input, options);
        value content = renderText(output);
        
        assertEquals(content,
            """<p>Test <!-- raw HTML omitted -->input<!-- raw HTML omitted --></p>
               """);
    }
    
    shared actual void verifySoftBreakOption(String input, RenderOptions options) {
        value output = render(input, options);
        value content = renderText(output);
        
        assertEquals(content,
            """<p>Line1ZZZLine2</p>
               """);
    }
    
    shared actual void verifySourcePosOption(String input, RenderOptions options) {
        value output = render(input, options);
        value paragraph = verifyElement<P>(output.first);
        
        verifyAttribute(paragraph, "data-sourcepos", "1:1-1:12");
    }
}
