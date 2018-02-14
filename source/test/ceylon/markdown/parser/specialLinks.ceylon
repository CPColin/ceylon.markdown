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
    NodeType,
    ParseOptions,
    Parser,
    transformSpecialLinks
}
import ceylon.test {
    assertEquals,
    assertFalse,
    assertTrue,
    test
}

{Boolean*} testSpecialLinksOptionParameters = {
    false,
    true
};

String specialLinkNodeText = "link";

String specialLinkNodeInput = "[[``specialLinkNodeText``]]";

String collectNodeText(Node root) {
    value text = StringBuilder();
    
    for ([entering, node] in root) {
        if (node.nodeType == NodeType.text, exists literal = node.literal) {
            text.append(literal);
        }
    }
    
    return text.string;
}

Node createSpecialLinkNode(Boolean specialLinksOption) {
    value options = ParseOptions {
        specialLinks = specialLinksOption;
    };
    value parser = Parser(options);
    value root = parser.parse(specialLinkNodeInput);
    value paragraph = root.lastChild;
    
    assertTrue(paragraph exists);
    
    assert (exists paragraph);
    
    assertEquals(paragraph.nodeType, NodeType.paragraph);
    
    value firstChild = paragraph.firstChild;
    
    assertTrue(firstChild exists);
    
    assert (exists firstChild);
    
    return paragraph;
}

test
shared void testSpecialLinksOptionDisabled() {
    value paragraph = createSpecialLinkNode(false);
    
    assertEquals(collectNodeText(paragraph), specialLinkNodeInput);
}

test
shared void testSpecialLinksOptionEnabled() {
    value paragraph = createSpecialLinkNode(true);
    value specialLink = paragraph.firstChild;
    
    assertTrue(specialLink exists);
    
    assert (exists specialLink);
    
    assertEquals(specialLink.nodeType, NodeType.specialLink);
    
    assertEquals(specialLink.literal, specialLinkNodeText);
}

test
shared void testTransformSpecialLinks() {
    value nodeType = NodeType.thematicBreak;
    function transform(String _) => Node(nodeType);
    value paragraph = createSpecialLinkNode(true);
    
    transformSpecialLinks(paragraph, transform);
    
    value child = paragraph.firstChild;
    
    assertTrue(child exists);
    
    assert (exists child);
    
    assertEquals(child.nodeType, nodeType);
    
    assertFalse(child.next exists);
}

test
shared void testTransformSpecialLinksFailure() {
    function transform(String _) => null;
    value paragraph = createSpecialLinkNode(true);
    
    transformSpecialLinks(paragraph, transform);
    
    value child = paragraph.firstChild;
    
    assertTrue(child exists);
    
    assert (exists child);
    
    assertEquals(child.nodeType, NodeType.specialLink);
    
    assertEquals(child.literal, specialLinkNodeText);
    
    assertFalse(child.next exists);
}
