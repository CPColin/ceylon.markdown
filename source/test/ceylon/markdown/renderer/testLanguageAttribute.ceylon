import ceylon.markdown.parser {
    Node,
    NodeType
}
import ceylon.markdown.renderer {
    RenderOptions,
    languageAttribute
}
import ceylon.test {
    assertEquals,
    parameters,
    test
}

Node codeBlock(String? explicitLanguage) {
    value node = Node(NodeType.codeBlock);
    
    node.info = explicitLanguage;
    node.literal = "foo";
    
    return node;
}

String? expectedLanguageAttribute(String? expectedLanguage)
        => if (exists expectedLanguage) then "language-``expectedLanguage``" else null;

String defaultLanguage = "defaultLanguage";

String otherLanguage = "otherLanguage";

{[String?, String?, String?]*} testLanguageAttributeParameters = {
    [null, null, null],
    [null, otherLanguage, otherLanguage],
    [defaultLanguage, null, defaultLanguage],
    [defaultLanguage, otherLanguage, otherLanguage]
};

test
parameters (`value testLanguageAttributeParameters`)
shared void testLanguageAttribute(String? defaultLanguage, String? explicitLanguage,
    String? expectedLanguage) {
    value options = RenderOptions {
        defaultLanguage = defaultLanguage;
    };
    value node = codeBlock(explicitLanguage);
    
    assertEquals(languageAttribute(options)(node),
        expectedLanguageAttribute(expectedLanguage));
}
