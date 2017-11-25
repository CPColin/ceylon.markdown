import ceylon.markdown.renderer {
    RenderOptions
}
import ceylon.test {
    test
}

// These tests are still a bit naive and probably need some refactoring to make them more robust and
// test more situations.

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
