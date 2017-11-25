import ceylon.test {
    assertEquals
}
import ceylon.markdown.renderer {
    RawHtmlRenderer,
    RenderOptions
}
import ceylon.markdown.parser {
    Parser
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
