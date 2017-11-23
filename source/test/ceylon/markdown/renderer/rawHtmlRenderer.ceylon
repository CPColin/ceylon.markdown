import ceylon.test {
    assertEquals,
    test
}
import ceylon.markdown.renderer {
    RawHtmlRenderer,
    RenderOptions
}
import ceylon.markdown.parser {
    Parser
}

// These are pretty dumb tests right now, but let's start here and get better soon.

test
shared void testDefaultLanguageOption() {
    value input = "~~~
                   foo
                   ~~~";
    value options = RenderOptions {
        defaultLanguage = "test";
    };
    value output = render(input, options);
    
    // TODO: could rely on languageAttribute() here
    assertEquals(output,
        """<pre><code class="language-test">foo
           </code></pre>
           """);
}

test
shared void testLinkHeadingsOption() {
    value input = "## Test Heading";
    value options = RenderOptions {
        linkHeadings = true;
    };
    value output = render(input, options);
    
    assertEquals(output,
        """<h2 id="test_heading"><a href="#test_heading">Test Heading</a></h2>
           """);
}

test
shared void testSafeOptionLinkDestination() {
    value input = "[link](javascript:void)";
    value options = RenderOptions {
        safe = true;
    };
    value output = render(input, options);
    
    assertEquals(output,
        """<p><a href="">link</a></p>
           """);
}

test
shared void testSafeOptionRawHtml() {
    value input = "Test <b>input</b>";
    value options = RenderOptions {
        safe = true;
    };
    value output = render(input, options);
    
    assertEquals(output,
        """<p>Test <!-- raw HTML omitted -->input<!-- raw HTML omitted --></p>
           """);
}

test
shared void testSoftBreakOption() {
    value input = "Line1
                   Line2";
    value options = RenderOptions {
        softBreak = "ZZZ";
    };
    value output = render(input, options);
    
    assertEquals(output,
        """<p>Line1ZZZLine2</p>
           """);
}

test
shared void testSourcePosOption() {
    value input = "Test *input*";
    value options = RenderOptions {
        sourcePos = true;
    };
    value output = render(input, options);
    
    assertEquals(output,
        """<p data-sourcepos="1:1-1:12">Test <em>input</em></p>
           """);
}

String render(String input, RenderOptions options) {
    value parser = Parser();
    value root = parser.parse(input);
    value renderer = RawHtmlRenderer(options);
    
    return renderer.render(root);
}
