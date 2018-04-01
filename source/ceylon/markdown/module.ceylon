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

"""A port of the [`commonmark.js`](https://github.com/commonmark/commonmark.js/) Markdown
   parser and renderer from JavaScript to Ceylon. Some parts have been made more ceylonic, for
   convenience, but the overall structure of the code still resembles the original JavaScript, to
   make incorporating upstream changes easier.
   
   ## Usage
   
   Similarly to `commonmark.js`, parsing and rendering are performed in separate steps:
   
   ``` ceylon
   value root = Parser().parse("## Hello World!");
   ```
   
   The parse operation returns the root of a tree of parsed nodes that can be passed to one of the
   renderers:
   
   ``` ceylon
   // Render as a String of HTML:
   value html = RawHtmlRenderer().render(root);
   
   // Render as a sequence of ceylon.html elements:
   value elements = CeylonHtmlRenderer().render(root);
   ```
   
   ### Options
   
   The parser and renderers support options similar to those found in `commonmark.js`:
   
   ``` ceylon
   value parser = Parser(ParseOptions { smart = true; });
   value renderer = RawHtmlRenderer(RenderOptions { defaultLanguage = "ceylon"; });
   ```
   
   The parser supports the following options:
   
   - `smart`: Enables "smart" processing of quotation marks, dashes, and ellipses.
   - `specialLinks`: Enables parsing of "special" links (see the next section).
   - `time`: Enables logging of timing statistics, for debugging.
   
   The renderers support the following options:
   
   - `defaultLanguage`: Indicates a language to be used when rendering code blocks that don't already specify one.
   - `linkHeadings`: Renders headings as links that scroll the page to themselves.
   - `safe`: Removes certain HTML from the output and limits the types of URL's in links and images.
   - `softBreak`: Specifies a snippet of HTML that should be used for "soft" breaks, which include single line breaks that don't interrupt the current paragraph.
   - `sourcePos`: Renders `data-sourcepos` attributes in the HTML that indicate where in the source text the Markdown that generated the current element was located.
   
   ### "Special" links
   
   When the `specialLinks` option is enabled, the parser will look for text surrounded by double
   brackets and parse them as nodes with a unique type. Code can subsequently search the tree for
   such nodes and apply a transformation on them. The `transformSpecialLinks` function has been
   provided to make this job easier.
   
   Here's an example of how one could transform special links:
   
   ``` ceylon
   import ceylon.markdown.parser {
       Node,
       NodeType,
       ParseOptions,
       Parser,
       transformSpecialLinks
   }
   import ceylon.markdown.renderer {
       RawHtmlRenderer
   }
   
   Node createLinkNode(String destination, String content) {
       value node = Node(NodeType.link);
       
       node.destination = destination;
       
       value text = Node(NodeType.text);
       
       text.literal = content;
       
       node.appendChild(text);
       
       return node;
   }
   
   shared void run() {
       value input
               = "## Testing special links
                  Broken link: [[broken]], working link: [[link]].";
       value parseOptions = ParseOptions {
           specialLinks = true;
       };
       value parser = Parser(parseOptions);
       value root = parser.parse(input);
       function transform(String content)
               => content != "broken" then createLinkNode("doc:``content``", content.uppercased);
       
       transformSpecialLinks(root, transform);
       
       value renderer = RawHtmlRenderer();
       
       print(renderer.render(root));
   }
   ```
"""
suppressWarnings("ceylonNamespace")
module ceylon.markdown "1.1.0" {
    import ceylon.buffer "1.3.3";
    import ceylon.collection "1.3.3";
    shared import ceylon.html "1.3.3";
    import ceylon.regex "1.3.3";
    import ceylon.uri "1.3.3";
}
