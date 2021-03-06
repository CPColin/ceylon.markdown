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
    Node
}
import ceylon.markdown.renderer {
    RawHtmlRenderer,
    RenderOptions
}
import ceylon.test {
    assertEquals,
    assertTrue
}

shared class RawHtmlRendererTests() extends RendererTests() {
    function renderNode(RenderOptions options, Node node) {
        value renderer = RawHtmlRenderer(options);
        
        return renderer.render(node);
    }
    
    shared actual void verifyLanguageAttribute(RenderOptions options, Node node,
        String? expectedAttribute) {
        value expectedCodeTag
                = if (exists expectedAttribute)
                then "<code class=\"``expectedAttribute``\">"
                else "<code>";
        value output = renderNode(options, node);
        
        assertEquals(output,
            "<pre>``expectedCodeTag``foo</code></pre>
             ");
    }
    
    shared actual void verifyLinkHeadingsOption(RenderOptions options, Node node) {
        value output = renderNode(options, node);
        value level = node.level else 0;
        
        assertEquals(output,
            "<h``level`` id=\"test_heading\"><a href=\"#test_heading\">Test Heading</a></h``level``>
             ");
    }
    
    shared actual void verifySafeOptionDestination(RenderOptions options, Node node,
        Boolean image) {
        value output = renderNode(options, node);
        
        if (image) {
            assertEquals(output,
                """<img src="" alt="" />""");
        } else {
            assertEquals(output,
                """<a href=""></a>""");
        }
    }
    
    shared actual void verifySafeOptionRawHtml(RenderOptions options, Node node) {
        value output = renderNode(options, node);
        
        assertEquals(output,
            "<!-- raw HTML omitted -->");
    }
    
    shared actual void verifySoftBreakOption(RenderOptions options, Node node, String softBreak) {
        value output = renderNode(options, node);
        
        assertEquals(output, softBreak);
    }
    
    shared actual void verifySourcePosOption(RenderOptions options, Node node, Integer startLine,
        Integer startColumn, Integer endLine, Integer endColumn) {
        value output = renderNode(options, node);
        value expectedAttribute
                = "data-sourcepos=\"``startLine``:``startColumn``-``endLine``:``endColumn``\"";
        
        assertTrue(output.firstInclusion(expectedAttribute) exists);
    }
    
    shared actual void verifySpecialLink(Node node) {
        value output = renderNode(RenderOptions(), node);
        
        assertEquals(output, "[[``node.literal else ""``]]");
    }
}
