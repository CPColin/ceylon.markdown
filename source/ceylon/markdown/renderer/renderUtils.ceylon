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
import ceylon.regex {
    regex
}

"Returns `true` if the grandparent of the given node, which is probably a Paragraph, is a \"tight\"
 list."
shared Boolean elideInTightList(Node node)
        => if (exists grandparent = node.parent?.parent,
            grandparent.nodeType == NodeType.list,
            grandparent.listTight else false) then true else false;

"Returns the given [[headingText]], converted into a form suitable for use in HTML ID attributes."
shared String headingId(String headingText) {
    function replacement(String match) {
        if (match == "-") {
            // Convert each hyphen into an underscore.
            return "_";
        } else if (exists character = match.first, character.whitespace) {
            // Convert each run of whitespace into an underscore.
            return "_";
        } else {
            // Drop all non-word characters.
            return "";
        }
    }
    
    return regex {
        expression = """-|\s+|[^\w\s]+""";
        global = true;
    }.replace(headingText.lowercased, replacement);
}

"Returns an ID attribute for the given [node], if the given [[options]] call for one."
shared String? headingIdAttribute(RenderOptions options)(Node node)
        => if (options.linkHeadings) then headingId(textContent(node)) else null;

"Returns a code language attribute for the given [[node]], using the language specified in the node,
 if there is one, or the default language specified in the given [[options]], if one was specified."
shared String? languageAttribute(RenderOptions options)(Node node)
        => if (exists language = node.info?.split(' '.equals)?.first, !language.empty)
        then "language-``language``"
        else (if (exists defaultLanguage = options.defaultLanguage)
            then "language-``defaultLanguage``"
            else null);

Integer? listStart(Node node)
        => if (exists start = node.listStart, start != 1) then start else null;

String? nonemptyTitle(Node node)
        => let (title = node.title else "")
            if (title.empty) then null else title;

Boolean potentiallyUnsafe(String url) {
    value regexSafeDataProtocol = regex {
        expression = """^data:image\/(?:png|gif|jpeg|webp)""";
        ignoreCase = true;
    };
    
    value regexUnsafeProtocol = regex {
        expression = "^javascript:|vbscript:|file:|data:";
        ignoreCase = true;
    };
    
    return regexUnsafeProtocol.test(url) && !regexSafeDataProtocol.test(url);
}

String rawHtmlOmitted(RenderOptions options)(Node node)
        => options.safe then "<!-- raw HTML omitted -->" else (node.literal else "");

String safeDestination(RenderOptions options)(Node node)
        => let (destination = node.destination else "")
            if (options.safe && potentiallyUnsafe(destination)) then "" else destination;

[<String->String>*] sourcePosAttribute(RenderOptions options)(Node node)
        => if (exists sourcePos = node.sourcePos, options.sourcePos)
        then ["data-sourcepos"->sourcePos.string] else empty;

String specialLink(Node node) => "[[``node.literal else ""``]]";

"Collects and returns all text content contained in the given [[root]] and its children."
String textContent(Node root) {
    value stringBuilder = StringBuilder();
    
    for ([entering, node] in root) {
        if (entering, exists literal = node.literal) {
            stringBuilder.append(literal);
        }
    }
    
    return stringBuilder.string;
}
