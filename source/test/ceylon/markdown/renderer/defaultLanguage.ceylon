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

String defaultLanguage = "defaultLanguage";
String otherLanguage = "otherLanguage";

{[String?, String?, String?]*} testWithDefaultLanguageParameters = {
    [null, null, null],
    [null, otherLanguage, otherLanguage],
    [defaultLanguage, null, defaultLanguage],
    [defaultLanguage, otherLanguage, otherLanguage]
};

test
parameters(`value testWithDefaultLanguageParameters`)
shared void testLanguageAttribute(String? defaultLanguage, String? nodeInfo, String? expected) {
    value renderOptions = RenderOptions {
        defaultLanguage = defaultLanguage;
    };
    value node = Node(NodeType.codeBlock);
    value expectedAttribute = if (exists expected) then "language-``expected``" else null;
    
    node.info = nodeInfo;
    
    assertEquals(languageAttribute(renderOptions)(node), expectedAttribute);
}
