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
    ListData,
    Node,
    NodeType
}
import ceylon.markdown.renderer {
    elideInTightList
}
import ceylon.test {
    assertEquals,
    parameters,
    test
}

{Boolean?*} testElideInTightListParameters = {
    null,
    false,
    true
};

[Node, Node] createTestListAndParagraph(Boolean? tight) {
    value list = Node(NodeType.list);
    
    list.listData = ListData {
        tight = tight;
    };
    
    value item = Node(NodeType.item);
    
    list.appendChild(item);
    
    value paragraph = Node(NodeType.paragraph);
    
    item.appendChild(paragraph);
    
    value text = Node(NodeType.text);
    
    text.literal = "text";
    
    paragraph.appendChild(text);
    
    return [list, paragraph];
}

Node createTestList(Boolean? tight) => createTestListAndParagraph(tight).first;

Node createTestParagraph(Boolean? tight) => createTestListAndParagraph(tight).last;

test
parameters(`value testElideInTightListParameters`)
void testElideInTightList(Boolean? tight) {
    value paragraph = createTestParagraph(tight);
    
    assertEquals(elideInTightList(paragraph), tight else false);
}
