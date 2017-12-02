// Ported from commonmark.js/lib/inline.js

import ceylon.collection {
    HashMap,
    MutableMap
}
import ceylon.regex {
    Regex,
    regex
}

class InlineParser() {
    value regexAutolink => regex {
        expression = """^<[A-Za-z][A-Za-z0-9.+-]{1,31}:[^<>\x00-\x20]*>""";
        ignoreCase = true;
    };
    
    value regexDashes => regex {
        expression = "--+";
        global = true;
    };
    
    value regexEllipses => regex {
        expression = """\.\.\.""";
        global = true;
    };
    
    value regexEmailAutolink = """^<([a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*)>""";
    
    value regexEntityHere => regex {
        expression = "^" + entity;
        ignoreCase = true;
    };
    
    value regexEscapable = "^" + escapable;
    
    value regexFinalSpace = " *$";
    
    value regexHtmlTag => regex {
        expression = htmlTag;
        ignoreCase = true;
    };
    
    value regexInitialSpace = "^ *";
    
    value regexLinkDestinationBraces
        = """^(?:[<](?:[^ <>\t\n\\\x00]|""" + escapedCharacter + """|\\)*[>])""";
    
    value regexLinkLabel = """^\[(?:[^\\\[\]]|""" + escapedCharacter + """|\\){0,1000}\]""";
    
    value regexLinkTitle = "^(?:"
        + """"(""" + escapedCharacter + """|[^"\x00])*""""
        + "|" + """'(""" + escapedCharacter + """|[^'\x00])*'"""
        + "|" + """\((""" + escapedCharacter + """|[^)\x00])*\))""";
    
    value regexMain => regex {
        expression = """^[^\n`\[\]\\!<&*_'"]+""";
        multiLine = true;
    };
    
    value regexPunctuation = """[!"#$%&'()*+,\-./:;<=>?@\[\]^_`{|}~\xA1\xA7\xAB\xB6\xB7\xBB\xBF\u037E\u0387\u055A-\u055F\u0589\u058A\u05BE\u05C0\u05C3\u05C6\u05F3\u05F4\u0609\u060A\u060C\u060D\u061B\u061E\u061F\u066A-\u066D\u06D4\u0700-\u070D\u07F7-\u07F9\u0830-\u083E\u085E\u0964\u0965\u0970\u0AF0\u0DF4\u0E4F\u0E5A\u0E5B\u0F04-\u0F12\u0F14\u0F3A-\u0F3D\u0F85\u0FD0-\u0FD4\u0FD9\u0FDA\u104A-\u104F\u10FB\u1360-\u1368\u1400\u166D\u166E\u169B\u169C\u16EB-\u16ED\u1735\u1736\u17D4-\u17D6\u17D8-\u17DA\u1800-\u180A\u1944\u1945\u1A1E\u1A1F\u1AA0-\u1AA6\u1AA8-\u1AAD\u1B5A-\u1B60\u1BFC-\u1BFF\u1C3B-\u1C3F\u1C7E\u1C7F\u1CC0-\u1CC7\u1CD3\u2010-\u2027\u2030-\u2043\u2045-\u2051\u2053-\u205E\u207D\u207E\u208D\u208E\u2308-\u230B\u2329\u232A\u2768-\u2775\u27C5\u27C6\u27E6-\u27EF\u2983-\u2998\u29D8-\u29DB\u29FC\u29FD\u2CF9-\u2CFC\u2CFE\u2CFF\u2D70\u2E00-\u2E2E\u2E30-\u2E42\u3001-\u3003\u3008-\u3011\u3014-\u301F\u3030\u303D\u30A0\u30FB\uA4FE\uA4FF\uA60D-\uA60F\uA673\uA67E\uA6F2-\uA6F7\uA874-\uA877\uA8CE\uA8CF\uA8F8-\uA8FA\uA8FC\uA92E\uA92F\uA95F\uA9C1-\uA9CD\uA9DE\uA9DF\uAA5C-\uAA5F\uAADE\uAADF\uAAF0\uAAF1\uABEB\uFD3E\uFD3F\uFE10-\uFE19\uFE30-\uFE52\uFE54-\uFE61\uFE63\uFE68\uFE6A\uFE6B\uFF01-\uFF03\uFF05-\uFF0A\uFF0C-\uFF0F\uFF1A\uFF1B\uFF1F\uFF20\uFF3B-\uFF3D\uFF3F\uFF5B\uFF5D\uFF5F-\uFF65]|\uD800[\uDD00-\uDD02\uDF9F\uDFD0]|\uD801\uDD6F|\uD802[\uDC57\uDD1F\uDD3F\uDE50-\uDE58\uDE7F\uDEF0-\uDEF6\uDF39-\uDF3F\uDF99-\uDF9C]|\uD804[\uDC47-\uDC4D\uDCBB\uDCBC\uDCBE-\uDCC1\uDD40-\uDD43\uDD74\uDD75\uDDC5-\uDDC9\uDDCD\uDDDB\uDDDD-\uDDDF\uDE38-\uDE3D\uDEA9]|\uD805[\uDCC6\uDDC1-\uDDD7\uDE41-\uDE43\uDF3C-\uDF3E]|\uD809[\uDC70-\uDC74]|\uD81A[\uDE6E\uDE6F\uDEF5\uDF37-\uDF3B\uDF44]|\uD82F\uDC9F|\uD836[\uDE87-\uDE8B]""";
    
    value regexSpaceAtEndOfLine = """^ *(?:\n|$)""";
    
    value regexSpaceNewline = """^ *(?:\n *)?""";
    
    value regexSpecialLink = """\[\[(.*?)\]\]""";
    
    value regexTicks = """`+""";
    
    value regexTicksHere = """^`+""";
    
    // Use explicit character list because \s doesn't match a no-break space on the JVM.
    value regexUnicodeWhitespaceCharacter = """^[ \f\n\r\t\v\u00a0\u1680\u180e\u2000-\u200a\u2028\u2029\u202f\u205f\u3000\ufeff]""";
    
    value regexWhitespace => regex {
        expression = """[ \t\n\x0b\x0c\x0d]+""";
        global = true;
    };
    
    value regexWhitespaceCharacter = """^[ \t\n\x0b\x0c\x0d]""";
    
    variable Bracket? brackets = null;
    
    variable Delimiter? delimiters = null;
    
    shared late variable ParseOptions options;
    
    shared late variable MutableMap<String, Reference> references;
    
    variable Integer position = 0;
    
    late variable String subject;
    
    shared void parse(Node block) {
        subject = if (exists stringContent = block.stringContent)
            then stringContent.string.trimmed
            else "";
        position = 0;
        delimiters = null;
        brackets = null;
        
        while (parseInline(block)) {}
        
        block.clearStringContent(); // allow raw string to be garbage collected (carryover from JS)
        
        processEmphasis(null);
    }
    
    "Attempt to parse a link reference, modifying refmap."
    shared Integer parseReference(String string, MutableMap<String, Reference> references) {
        subject = string;
        position = 0;
        
        // TODO: it might not make sense to worry about this
        value startPosition = position;
        
        // label:
        String rawLabel;
        value matchChars = parseLinkLabel();
        
        if (matchChars == 0) {
            return 0;
        } else {
            rawLabel = subject.substring(0, matchChars);
        }
        
        // colon:
        if (exists character = peek(), character == ':') {
            position++;
        } else {
            position = startPosition;
            
            return 0;
        }
        
        //  link url
        spaceNewline();
        
        value destination = parseLinkDestination();
        
        if (!exists destination) {
            position = startPosition;
            return 0;
        } else if (destination.empty) {
            position = startPosition;
            return 0;
        }
        
        value beforeTitle = position;
        
        spaceNewline();
        
        variable String title;
        
        if (exists parsedTitle = parseLinkTitle()) {
            title = parsedTitle;
        } else {
            title = "";
            // rewind before spaces
            position = beforeTitle;
        }
        
        // make sure we're at line end:
        Boolean atLineEnd;
        
        if (!match(regexSpaceAtEndOfLine) exists) {
            if (title.empty) {
                atLineEnd = false;
            } else {
                // the potential title we found is not at the line end,
                // but it could still be a legal link reference if we
                // discard the title
                title = "";
                // rewind before spaces
                position = beforeTitle;
                // and instead check if the link URL is at the line end
                atLineEnd = match(regexSpaceAtEndOfLine) exists;
            }
        } else {
            atLineEnd = true;
        }
        
        if (!atLineEnd) {
            position = startPosition;
            
            return 0;
        }
        
        value normLabel = normalizeReference(rawLabel);
        
        if (normLabel.empty) {
            // label must contain non-whitespace characters
            this.position = startPosition;
            
            return 0;
        }
        
        if (!references.defines(normLabel)) {
            references[normLabel] = Reference {
                destination = destination;
                title = title;
            };
        }
        
        return position - startPosition;
    }
    
    void addBracket(Node node, Integer index, Boolean image) {
        if (exists bracket = brackets) {
            bracket.bracketAfter = true;
        }
        
        brackets = Bracket {
            image = image;
            index = index;
            node = node;
            previous = brackets;
            previousDelimiter = delimiters;
        };
    }
    
    void removeBracket() {
        if (exists bracket = brackets) {
            brackets = bracket.previous;
        }
    }
    
    void removeDelimiter(Delimiter delimiter) {
        if (exists previous = delimiter.previous) {
            previous.next = delimiter.next;
        }
        
        if (exists next = delimiter.next) {
            next.previous = delimiter.previous;
        } else {
            // top of stack
            delimiters = delimiter.previous;
        }
    }
    
    void removeDelimitersBetween(Delimiter bottom, Delimiter top) {
        if (!bothNullOrEqual(bottom.next, top)) {
            bottom.next = top;
            top.previous = bottom;
        }
    }
    
    "Attempts to match the given [[expression]] and, on success, advances the current [[position]]
     past its end."
    String? match(Regex|String expression, Integer? group = null) {
        value match = (if (is String expression) then regex(expression) else expression)
                .find(subject.substring(position));
        
        if (exists match) {
            position += match.end;
            
            if (exists group) {
                return match.groups[group];
            } else {
                return match.matched;
            }
        } else {
            return null;
        }
    }
    
    "Parse zero or more space characters, including at most one newline"
    Boolean spaceNewline() {
        match(regexSpaceNewline);
        
        return true;
    }
    
    Boolean parseInline(Node block) {
        Boolean result;
        value character = peek();
        
        if (!exists character) {
            return false;
        }
        
        switch (character)
        case ('\n') {
            result = parseNewline(block);
        }
        case ('\\') {
            result = parseBackslash(block);
        }
        case ('`') {
            result = parseBackticks(block);
        }
        case ('*' | '_') {
            result = handleDelim(character, block);
        }
        case ('\'' | '"') {
            result = options.smart && handleDelim(character, block);
        }
        case ('[') {
            result = (options.specialLinks && parseSpecialLink(block))
                || parseOpenBracket(block);
        }
        case ('!') {
            result = parseBang(block);
        }
        case (']') {
            result = parseCloseBracket(block);
        }
        case ('<') {
            result = parseAutolink(block) || parseHtmlTag(block);
        }
        case ('&') {
            result = parseEntity(block);
        }
        else {
            result = parseString(block);
        }
        
        if (!result) {
            position++;
            block.appendChild(textNode(character.string));
        }
        
        return true;
    }
    
    // Scan a sequence of characters with code cc, and return information about
    // the number of delimiters and whether they are positioned such that
    // they can open and/or close emphasis or strong emphasis.  A utility
    // function for strong/emph parsing.
    [Integer, Boolean, Boolean]? scanDelims(Character character) {
        value startPosition = position;
        variable value numDelims = 0;
        
        if (character == '\'' || character == '"') {
            numDelims++;
            position++;
        } else {
            while (exists peek = peek(), peek == character) {
                numDelims++;
                position++;
            }
        }
        
        if (numDelims == 0) {
            return null;
        }
        
        value characterBefore = subject[startPosition - 1] else '\n';
        value characterAfter = peek() else '\n';
        
        value afterIsWhitespace = regex(regexUnicodeWhitespaceCharacter).test(characterAfter.string);
        value afterIsPunctuation = regex(regexPunctuation).test(characterAfter.string);
        value beforeIsWhitespace = regex(regexUnicodeWhitespaceCharacter).test(characterBefore.string);
        value beforeIsPunctuation = regex(regexPunctuation).test(characterBefore.string);
        
        value leftFlanking = !afterIsWhitespace
            && (!afterIsPunctuation || beforeIsWhitespace || beforeIsPunctuation);
        value rightFlanking = !beforeIsWhitespace
            && (!beforeIsPunctuation || afterIsWhitespace || afterIsPunctuation);
        
        Boolean canOpen;
        Boolean canClose;
        
        if (character == '_') {
            canOpen = leftFlanking && (!rightFlanking || beforeIsPunctuation);
            canClose = rightFlanking && (!leftFlanking || afterIsPunctuation);
        } else if (character == '\'' || character == '"') {
            canOpen = leftFlanking && !rightFlanking;
            canClose = rightFlanking;
        } else {
            canOpen = leftFlanking;
            canClose = rightFlanking;
        }
        
        position = startPosition;
        
        return [numDelims, canOpen, canClose];
    }
    
    "Handle a delimiter marker for emphasis or a quote."
    Boolean handleDelim(Character character, Node block) {
        value scannedDelimiters = scanDelims(character);
        
        if (!exists scannedDelimiters) {
            return false;
        }
        
        value [numDelims, canOpen, canClose] = scannedDelimiters;
        value startPosition = position;
        
        position += numDelims;
        
        String contents;
        
        if (character == '\'') {
            contents = "\{RIGHT SINGLE QUOTATION MARK}";
        } else if (character == '"') {
            contents = "\{LEFT DOUBLE QUOTATION MARK}";
        } else {
            contents = subject.substring(startPosition, position);
        }
        
        value node = textNode(contents);
        block.appendChild(node);
        
        // Add entry to stack for this opener
        delimiters = Delimiter {
            canClose = canClose;
            canOpen = canOpen;
            character = character;
            node = node;
            numDelims = numDelims;
            previous = delimiters;
        };
        
        if (exists previous = delimiters?.previous) {
            previous.next = delimiters;
        }
        
        return true;
    }
    
    "Attempt to parse an autolink (URL or email in pointy brackets)."
    Boolean parseAutolink(Node block) {
        String prefix;
        String destination;
        
        if (exists match = match(regexEmailAutolink)) {
            prefix = "mailto:";
            destination = match.substring(1, match.size - 1);
        } else if (exists match = match(regexAutolink)) {
            prefix = "";
            destination = match.substring(1, match.size - 1);
        } else {
            return false;
        }
        
        value node = Node(NodeType.link);
        
        node.destination = prefix + normalizeUri(destination);
        node.title = "";
        node.appendChild(textNode(destination));
        
        block.appendChild(node);
        
        return true;
    }
    
    "Parse a backslash-escaped special character, adding either the escaped
     character, a hard line break (if the backslash is followed by a newline),
     or a literal backslash to the block's children.  Assumes current character
     is a backslash."
    Boolean parseBackslash(Node block) {
        position++;
        
        value character = peek();
        
        if (exists character, character == '\n') {
            position++;
            block.appendChild(Node(NodeType.lineBreak));
        } else if (exists character, regex(regexEscapable).test(character.string)) {
            position++;
            block.appendChild(textNode(character.string));
        } else {
            block.appendChild(textNode("\\"));
        }
        
        return true;
    }
    
    "Attempt to parse backticks, adding either a backtick code span or a
     literal sequence of backticks."
    Boolean parseBackticks(Node block) {
        value ticks = match(regexTicksHere);
        
        if (!exists ticks) {
            return false;
        }
        
        value afterOpenTicks = position;
        
        while (exists matched = match(regexTicks)) {
            if (matched == ticks) {
                value node = Node(NodeType.code);
                node.literal = regexWhitespace.replace(
                    subject
                        .substring(afterOpenTicks, position - ticks.size)
                        .trimmed,
                    " ");
                block.appendChild(node);
                
                return true;
            }
        }
        
        // If we got here, we didn't match a closing backtick sequence.
        position = afterOpenTicks;
        block.appendChild(textNode(ticks));
        
        return true;
    }
    
    "IF next character is [, and ! delimiter to delimiter stack and
     add a text node to block's children.  Otherwise just add a text node."
    Boolean parseBang(Node block) {
        value startPosition = position;
        
        position++;
        
        if (exists character = peek(), character == '[') {
            position++;
            
            value node = textNode("![");
            
            block.appendChild(node);
            
            // Add entry to stack for this opener
            addBracket(node, startPosition + 1, true);
        } else {
            block.appendChild(textNode("!"));
        }
        
        return true;
    }
    
    "Try to match close bracket against an opening in the delimiter
     stack.  Add either a link or image, or a plain [ character,
     to block's children.  If there is a matching delimiter,
     remove it from the delimiter stack."
    Boolean parseCloseBracket(Node block) {
        position++;
        
        value startPosition = position;
        
        // get last [ or ![
        value opener = brackets;
        
        if (!exists opener) {
            // no matched opener, just return a literal
            block.appendChild(textNode("]"));
            
            return true;
        }
        
        if (!opener.active) {
            // no matched opener, just return a literal
            block.appendChild(textNode("]"));
            
            // take opener off brackets stack
            removeBracket();
            
            return true;
        }
        
        // If we got here, open is a potential opener
        
        // Check to see if we have a link/image
        
        value savePosition = position;
        variable Boolean matched = false;
        variable String? destination = null;
        variable String? title = null;
        
        // Inline link?
        if (exists openParen = peek(), openParen == '(') {
            position++;
            
            if (spaceNewline(),
                    exists parsedDestination = parseLinkDestination(),
                    spaceNewline()) {
                // make sure there's a space before the title:
                value parsedTitle
                    = if (regex(regexWhitespaceCharacter)
                        .test(subject.substring(position - 1, position)))
                    then parseLinkTitle() else null;
                
                if (spaceNewline(),
                        exists closeParen = peek(), closeParen == ')') {
                    position++;
                    matched = true;
                    destination = parsedDestination;
                    title = parsedTitle;
                }
            }
            
            if (!matched) {
                position = savePosition;
            }
        }
        
        if (!matched) {
            // Next, see if there's a link label
            value beforeLabel = position;
            value labelCount = parseLinkLabel();
            String? referenceLabel;
            
            if (labelCount > 2) {
                referenceLabel = subject.substring(beforeLabel, beforeLabel + labelCount);
            } else if (!opener.bracketAfter) {
                // Empty or missing second label means to use the first label as the reference.
                // The reference must not contain a bracket. If we know there's a bracket, we don't even bother checking it.
                referenceLabel = subject.substring(opener.index, startPosition);
            } else {
                referenceLabel = null;
            }
            
            if (labelCount == 0) {
                // If shortcut reference link, rewind before spaces we skipped.
                position = savePosition;
            }
            
            if (exists referenceLabel) {
                // lookup rawlabel in refmap
                if (exists link = references[normalizeReference(referenceLabel)]) {
                    destination = link.destination;
                    title = link.title;
                    matched = true;
                }
            }
        }
        
        if (matched) {
            value node = Node(opener.image then NodeType.image else NodeType.link);
            node.destination = destination;
            node.title = title else "";
            
            variable value currentNode = opener.node.next;
            
            while (exists tmp = currentNode) {
                value next = tmp.next;
                tmp.unlink();
                node.appendChild(tmp);
                currentNode = next;
            }
            
            block.appendChild(node);
            processEmphasis(opener.previousDelimiter);
            removeBracket();
            opener.node.unlink();
            
            // We remove this bracket and processEmphasis will remove later delimiters.
            // Now, for a link, we also deactivate earlier link openers.
            // (no links in links)
            if (!opener.image) {
                variable value currentBracket = brackets;
                
                while (exists bracket = currentBracket) {
                    if (!bracket.image) {
                        bracket.active = false; // deactivate this opener
                    }
                    
                    currentBracket = bracket.previous;
                }
            }
        } else { // no match
            removeBracket();  // remove this opener from stack
            position = startPosition;
            block.appendChild(textNode("]"));
        }
        
        return true;
    }
    
    "Attempt to parse an entity."
    Boolean parseEntity(Node block) {
        if (exists match = match(regexEntityHere)) {
            block.appendChild(textNode(entities.decode(match)));
            
            return true;
        } else {
            return false;
        }
    }
    
    "Attempt to parse a raw HTML tag."
    Boolean parseHtmlTag(Node block) {
        if (exists match = match(regexHtmlTag)) {
            value node = Node(NodeType.htmlInline);
            
            node.literal = match;
            
            block.appendChild(node);
            
            return true;
        } else {
            return false;
        }
    }
    
    "Attempt to parse link destination, returning the string or
     null if no match."
    String? parseLinkDestination() {
        if (exists match = match(regexLinkDestinationBraces)) {
            // chop off surrounding <..>:
            return normalizeUri(unescapeString(match.substring(1, match.size - 1)));
        } else {
            value savePosition = position;
            variable value openParens = 0;
            
            while (exists character = peek()) {
                if (character == '\\') {
                    position++;
                    if (peek() exists) {
                        position++;
                    }
                } else if (character == '(') {
                    position++;
                    openParens++;
                } else if (character == ')') {
                    if (openParens < 1) {
                        break;
                    } else {
                        position++;
                        openParens--;
                    }
                } else if (regex(regexWhitespaceCharacter).test(character.string)) {
                    break;
                } else {
                    position++;
                }
            }
            
            value result = subject[savePosition:position-savePosition];
            
            return normalizeUri(unescapeString(result));
        }
    }
    
    "Attempt to parse a link label, returning number of characters parsed."
    Integer parseLinkLabel() {
        // Note:  our regex will allow something of form [..\];
        // we disallow it here rather than using lookahead in the regex:
        if (exists label = match(regexLinkLabel),
                label.size <= 1000,
                !regex("""[^\\]\\\]$""").test(label)) {
            return label.size;
        } else {
            return 0;
        }
    }
    
    "Attempt to parse link title (sans quotes), returning the string
     or null if no match."
    String? parseLinkTitle() {
        if (exists title = match(regexLinkTitle)) {
            // chop off quotes from title and unescape:
            return unescapeString(title.substring(1, title.size - 1));
        } else {
            return null;
        }
    }
    
    Boolean parseNewline(Node block) {
        position++; // assume we're at a \n
        
        NodeType type;
        
        // check previous node for trailing spaces
        if (exists lastChild = block.lastChild,
                lastChild.nodeType == NodeType.text,
                exists literal = lastChild.literal,
                literal.endsWith(" ")) {
            lastChild.literal = regex(regexFinalSpace).replace(literal, "");
            type = literal.endsWith("  ") then NodeType.lineBreak else NodeType.softBreak;
        } else {
            type = NodeType.softBreak;
        }
        
        block.appendChild(Node(type));
        
        match(regexInitialSpace); // gobble leading spaces in next line
        
        return true;
    }
    
    "Add open bracket to delimiter stack and add a text node to block's children."
    Boolean parseOpenBracket(Node block) {
        value startPosition = position;
        
        position++;
        
        value node = textNode("[");
        
        block.appendChild(node);
        
        // Add entry to stack for this opener
        addBracket(node, startPosition, false);
        
        return true;
    }
    
    Boolean parseSpecialLink(Node block) {
        if (exists match = match(regexSpecialLink, 0)) {
            value node = Node(NodeType.specialLink);
            
            node.literal = match;
            
            block.appendChild(node);
            
            return true;
        } else {
            return false;
        }
    }
    
    Boolean parseString(Node block) {
        if (exists match = match(regexMain)) {
            if (options.smart) {
                value replacement = regexDashes.replace(
                        regexEllipses.replace(match, "\{HORIZONTAL ELLIPSIS}"),
                        (String dashes) {
                    Integer enCount;
                    Integer emCount;
                    
                    if (dashes.size % 3 == 0) { // If divisible by 3, use all em dashes
                        enCount = 0;
                        emCount = dashes.size / 3;
                    } else if (dashes.size % 2 == 0) { // If divisible by 2, use all en dashes
                        enCount = dashes.size / 2;
                        emCount = 0;
                    } else if (dashes.size % 3 == 2) { // If 2 extra dashes, use en dash for last 2; em dashes for rest
                        enCount = 1;
                        emCount = (dashes.size - 2) / 3;
                    } else { // Use en dashes for last 4 hyphens; em dashes for rest
                        enCount = 2;
                        emCount = (dashes.size - 4) / 3;
                    }
                    
                    return "\{EM DASH}".repeat(emCount) + "\{EN DASH}".repeat(enCount);
                });
                
                block.appendChild(textNode(replacement));
            } else {
                block.appendChild(textNode(match));
            }
            
            return true;
        } else {
            return false;
        }
    }
    
    Character? peek() => subject[position];
    
    void processEmphasis(Delimiter? stackBottom) {
        variable value oddMatch = false;
        value openersBottom = HashMap<Character, Delimiter?> {
            '_' -> stackBottom,
            '*' -> stackBottom,
            '\'' -> stackBottom,
            '"' -> stackBottom
        };
        
        // find first closer above stack_bottom:
        variable value varCloser = delimiters;
        
        while (exists closer = varCloser, !bothNullOrEqual(closer.previous, stackBottom)) {
            varCloser = closer.previous;
        }
    
        // move forward, looking for closers, and handling each
        while (exists closer = varCloser) {
            value closerCharacter = closer.character;
            
            if (!closer.canClose) {
                varCloser = closer.next;
            } else {
                // found emphasis closer. now look back for first matching opener:
                variable value varOpener = closer.previous;
                variable value openerFound = false;
                
                while (exists opener = varOpener,
                        !bothNullOrEqual(opener, stackBottom),
                        !bothNullOrEqual(opener, openersBottom[closerCharacter])) {
                    oddMatch = (closer.canOpen || opener.canClose)
                        && (opener.originalDelims + closer.originalDelims) % 3 == 0;
                    
                    if (opener.character == closer.character && opener.canOpen && !oddMatch) {
                        openerFound = true;
                        break;
                    }
                    
                    varOpener = opener.previous;
                }
                
                value oldCloser = closer;
                
                if (closerCharacter == '*' || closerCharacter == '_') {
                    if (!openerFound) {
                        varCloser = closer.next;
                    } else if (exists opener = varOpener) {
                        // calculate actual number of delimiters used from closer
                        
                        value useDelimiters
                                = (closer.numDelims >= 2 && opener.numDelims >= 2) then 2 else 1;
                        value openerInl = opener.node;
                        value closerInl = closer.node;
                        
                        // remove used delimiters from stack elts and inlines
                        opener.numDelims -= useDelimiters;
                        closer.numDelims -= useDelimiters;
                        
                        if (exists literal = openerInl.literal) {
                            openerInl.literal = literal.substring(0, literal.size - useDelimiters);
                        }
                        
                        if (exists literal = closerInl.literal) {
                            closerInl.literal = literal.substring(0, literal.size - useDelimiters);
                        }
                        
                        // build contents for new emph element
                        value emph = Node(useDelimiters == 1
                                then NodeType.emphasis else NodeType.strong);
                        variable value varTemp = openerInl.next;
                        
                        while (exists temp = varTemp, temp != closerInl) {
                            value next = temp.next;
                            temp.unlink();
                            emph.appendChild(temp);
                            varTemp = next;
                        }
                        
                        openerInl.insertAfter(emph);
                        
                        // remove elts between opener and closer in delimiters stack
                        removeDelimitersBetween(opener, closer);
                        
                        // if opener has 0 delims, remove it and the inline
                        if (opener.numDelims == 0) {
                            openerInl.unlink();
                            removeDelimiter(opener);
                        }
                        
                        if (closer.numDelims == 0) {
                            closerInl.unlink();
                            value tempStack = closer.next;
                            removeDelimiter(closer);
                            varCloser = tempStack;
                        }
                    }
                } else if (closerCharacter == '\'') {
                    closer.node.literal = "\{RIGHT SINGLE QUOTATION MARK}";
                    if (openerFound, exists opener = varOpener) {
                        opener.node.literal = "\{LEFT SINGLE QUOTATION MARK}";
                    }
                    varCloser = closer.next;
                } else if (closerCharacter == '"') {
                    closer.node.literal = "\{RIGHT DOUBLE QUOTATION MARK}";
                    if (openerFound, exists opener = varOpener) {
                        opener.node.literal = "\{LEFT DOUBLE QUOTATION MARK}";
                    }
                    varCloser = closer.next;
                }
                
                if (!openerFound && !oddMatch) {
                    // Set lower bound for future searches for openers:
                    // We don't do this with odd_match because a **
                    // that doesn't match an earlier * might turn into
                    // an opener, and the * might be matched by something
                    // else.
                    openersBottom[closerCharacter] = oldCloser.previous;
                    if (!oldCloser.canOpen) {
                        // We can remove a closer that can't be an opener,
                        // once we've seen there's no matching opener:
                        removeDelimiter(oldCloser);
                    }
                }
            }
        }
        
        // remove all delimiters
        while (exists delimiter = delimiters, !bothNullOrEqual(delimiter, stackBottom)) {
            removeDelimiter(delimiter);
        }
    }
}
