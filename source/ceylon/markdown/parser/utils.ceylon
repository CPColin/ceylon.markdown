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

// Ported from commonmark.js/lib/blocks.js, common.js, and inline.js

import ceylon.regex {
    Regex,
    regex
}

String tagName = "[A-Za-z][A-Za-z0-9-]*";
String attributeName = "[a-zA-Z_:][a-zA-Z0-9:._-]*";
String unquotedValue = """[^"'=<>`\x00-\x20]+""";
String singleQuotedValue = "'[^']*'";
String doubleQuotedValue = """"[^"]*"""";
String attributeValue = "(?:" + unquotedValue + "|" + singleQuotedValue + "|" + doubleQuotedValue + ")";
String attributeValueSpec = "(?:" + "\\s*=" + "\\s*" + attributeValue + ")";
String attribute = "(?:" + "\\s+" + attributeName + attributeValueSpec + "?)";
String openTag = "<" + tagName + attribute + "*" + "\\s*/?>";
String closeTag = "</" + tagName + "\\s*[>]";
String htmlComment = "<!---->|<!--(?:-?[^>-])(?:-?[^-])*-->";
String processingInstruction = "[<][?].*?[?][>]";
String declaration = """<![A-Z]+\s+[^>]*>""";
String cData = """<!\[CDATA\[[\s\S]*?\]\]>""";
String htmlTag = "(?:" + openTag + "|" + closeTag + "|" + htmlComment + "|" + processingInstruction
    + "|" + declaration + "|" + cData + ")";

String regexNonSpace = """[^ \t\f\v\r\n]""";

String escapable = """[!"#$%&'()*+,./:;<=>?@\[\\\]^_`{|}~-]""";

String escapedCharacter = """\\""" + escapable;

"Regex that matches HTML entities."
shared String entity = "&(?:#x[a-f0-9]{1,8}|#[0-9]{1,8}|[a-z][a-z0-9]{1,31});";

Regex regexEntityOrEscapedCharacter => regex {
    expression = escapedCharacter + "|" + entity;
    global = true;
    ignoreCase = true;
};

Boolean bothNullOrEqual<Type>(Type value1, Type value2) {
    if (exists value1, exists value2) {
        return value1 == value2;
    } else if (!exists value1, !exists value2) {
        return true;
    } else {
        return false;
    }
}

Boolean endsWithBlankLine(variable Node? varBlock) {
    while (exists block = varBlock) {
        if (block.lastLineBlank) {
            return true;
        }
        
        if (block.nodeType == NodeType.list || block.nodeType == NodeType.item) {
            varBlock = block.lastChild;
        } else {
            break;
        }
    }
    return false;

}

Boolean isBlank(String string) {
    return !regex(regexNonSpace).test(string);
}

Boolean isSpaceOrTab(Character character) {
    return character == ' ' || character == '\t';
}

Boolean peek(String string, Integer position, Boolean(Character) match) {
    value character = string[position];
    
    return if (exists character) then match(character) else false;
}

Node textNode(String text) {
    value node = Node(NodeType.text);
    
    node.literal = text;
    
    return node;
}

String unescapeCharacter(String string) {
    if (string.startsWith("\\")) {
        return string.rest;
    } else {
        return entities.decode(string);
    }
}

"Replace entities and backslash escapes with literal characters."
String unescapeString(variable String string) {
    if (string.containsAny({'\\', '&'})) {
        return regexEntityOrEscapedCharacter.replace(string, unescapeCharacter);
    } else {
        return string;
    }
}

// Adapted from commonmark.js/normalize-reference.js

"Normalize reference label: collapse internal whitespace
 to single space, remove leading/trailing whitespace, case fold."
String normalizeReference(String reference)
    => regex {
        expression = """[ \t\r\n]+""";
        global = true;
    }.replace(reference.substring(1, reference.size - 1), " ").trimmed.lowercased;
