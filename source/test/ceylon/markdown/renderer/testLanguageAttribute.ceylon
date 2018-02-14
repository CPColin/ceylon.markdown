/*****************************************************************************
 * Copyright © 2018 Colin Bartolome
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy
 * of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 *****************************************************************************/

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
