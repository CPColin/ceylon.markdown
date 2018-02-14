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
    headingIdAttribute
}
import ceylon.test {
    assertEquals,
    parameters,
    test
}

{[Boolean, String, String?]*} testHeadingIdAttributeParameters = {
    [false, "Test Heading", null],
    [true, "Test Heading", "test_heading"]
};

test
parameters (`value testHeadingIdAttributeParameters`)
shared void testHeadingIdAttribute(Boolean linkHeadings, String heading, String? expected) {
    value options = RenderOptions {
        linkHeadings = linkHeadings;
    };
    value node = Node(NodeType.heading);
    
    node.literal = heading;
    
    assertEquals(headingIdAttribute(options)(node), expected);
}
