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

test
shared void testLinkHeadingsOption() {
    value input = "## Test Heading";
    value parser = Parser();
    value root = parser.parse(input);
    value renderOptions = RenderOptions {
        linkHeadings = true;
    };
    value renderer = RawHtmlRenderer(renderOptions);
    value output = renderer.render(root);
    
    // This is a pretty dumb test, but let's start here and get better soon.
    assertEquals(output,
        """<h2 id="test_heading"><a href="#test_heading">Test Heading</a></h2>
           """);
}
