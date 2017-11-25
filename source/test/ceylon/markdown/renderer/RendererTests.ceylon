import ceylon.markdown.parser {
    Parser
}
import ceylon.markdown.renderer {
    CeylonHtmlRenderer,
    RawHtmlRenderer,
    RenderOptions
}
import ceylon.test {
    assertEquals,
    assertTrue,
    fail,
    test
}
import ceylon.html {
    A,
    Code,
    H2,
    Node,
    P,
    Pre
}

// These tests are still a bit naive and probably need some refactoring to make them more robust and
// test more situations. Eventually, this file will be broken up to be one class per file.

shared abstract class RendererTests() {
    // TODO: parameterize, test that the default is overridden by explicit value
    test
    shared void testDefaultLanguageOption() {
        value input = "~~~
                       foo
                       ~~~";
        value options = RenderOptions {
            defaultLanguage = "test";
        };
        
        verifyDefaultLanguageOption(input, options);
    }
    
    test
    shared void testLinkHeadingsOption() {
        value input = "## Test Heading";
        value options = RenderOptions {
            linkHeadings = true;
        };
        
        verifyLinkHeadingsOption(input, options);
    }
    
    // TODO: need to check images, too
    test
    shared void testSafeOptionLinkDestination() {
        value input = "[link](javascript:void)";
        value options = RenderOptions {
            safe = true;
        };
        
        verifySafeOptionLinkDestination(input, options);
    }
    
    test
    shared void testSafeOptionRawHtml() {
        value input = "Test <b>input</b>";
        value options = RenderOptions {
            safe = true;
        };
        
        verifySafeOptionRawHtml(input, options);
    }
    
    test
    shared void testSoftBreakOption() {
        value input = "Line1
                       Line2";
        value options = RenderOptions {
            softBreak = "ZZZ";
        };
        
        verifySoftBreakOption(input, options);
    }
    
    // TODO: need every element type that uses the attribute
    // or a test for every element type in general that additionally checks the attribute
    test
    shared void testSourcePosOption() {
        value input = "Test *input*";
        value options = RenderOptions {
            sourcePos = true;
        };
        
        verifySourcePosOption(input, options);
    }
    
    shared formal void verifyDefaultLanguageOption(String input, RenderOptions options);
    
    shared formal void verifyLinkHeadingsOption(String input, RenderOptions options);
    
    shared formal void verifySafeOptionLinkDestination(String input, RenderOptions options);
    
    shared formal void verifySafeOptionRawHtml(String input, RenderOptions options);
    
    shared formal void verifySoftBreakOption(String input, RenderOptions options);
    
    shared formal void verifySourcePosOption(String input, RenderOptions options);
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

shared class RawHtmlRendererTests() extends RendererTests() {
    function render(String input, RenderOptions options) {
        value parser = Parser();
        value root = parser.parse(input);
        value renderer = RawHtmlRenderer(options);
        
        return renderer.render(root);
    }
    
    shared actual void verifyDefaultLanguageOption(String input, RenderOptions options) {
        value output = render(input, options);
        
        assertEquals(output,
            """<pre><code class="language-test">foo
               </code></pre>
               """);
    }
    
    shared actual void verifyLinkHeadingsOption(String input, RenderOptions options) {
        value output = render(input, options);
        
        assertEquals(output,
            """<h2 id="test_heading"><a href="#test_heading">Test Heading</a></h2>
               """);
    }
    
    shared actual void verifySafeOptionLinkDestination(String input, RenderOptions options) {
        value output = render(input, options);
        
        assertEquals(output,
            """<p><a href="">link</a></p>
               """);
    }
    
    shared actual void verifySafeOptionRawHtml(String input, RenderOptions options) {
        value output = render(input, options);
        
        assertEquals(output,
            """<p>Test <!-- raw HTML omitted -->input<!-- raw HTML omitted --></p>
               """);
    }
    
    shared actual void verifySoftBreakOption(String input, RenderOptions options) {
        value output = render(input, options);
        
        assertEquals(output,
            """<p>Line1ZZZLine2</p>
               """);
    }
    
    shared actual void verifySourcePosOption(String input, RenderOptions options) {
        value output = render(input, options);
        
        assertEquals(output,
            """<p data-sourcepos="1:1-1:12">Test <em>input</em></p>
               """);
    }
}
