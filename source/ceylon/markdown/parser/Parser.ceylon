// Ported from commonmark.js/lib/blocks.js

import ceylon.collection {
    HashMap,
    MutableMap
}
import ceylon.regex {
    regex
}

interface Block {
    shared formal Boolean acceptsLines;
    
    shared formal Boolean canContain(NodeType type);
    
    shared formal Continuation continuation;
    
    shared formal void finalize();
}

shared class Parser {
    value codeIndent = 4;
    
    value regexAtxHeadingMarker = """^#{1,6}(?:[ \t]+|$)""";
    
    value regexBulletListMarker = "^[*+-]";
    
    value regexClosingCodeFence = """^(?:`{3,}|~{3,})(?= *$)""";
    
    value regexCodeFence = """^`{3,}(?!.*`)|^~{3,}(?!.*~)""";
    
    value regexOrderedListMarker = """^(\d{1,9})([.)])""";
    
    value regexSetextHeadingLine = """^(?:=+|-+)[ \t]*$""";
    
    value regexThematicBreak = """^(?:(?:\*[ \t]*){3,}|(?:_[ \t]*){3,}|(?:-[ \t]*){3,})[ \t]*$""";
    
    value regexHtmlBlockOpens = [
        regex("."), // dummy for 0
        regex {
            expression = """^<(?:script|pre|style)(?:\s|>|$)""";
            ignoreCase = true;
        },
        regex("^<!--"),
        regex("^<[?]"),
        regex("^<![A-Z]"),
        regex("""^<!\[CDATA\["""),
        regex {
            expression = """^<[/]?(?:address|article|aside|base|basefont|blockquote|body|caption|center|col|colgroup|dd|details|dialog|dir|div|dl|dt|fieldset|figcaption|figure|footer|form|frame|frameset|h[123456]|head|header|hr|html|iframe|legend|li|link|main|menu|menuitem|meta|nav|noframes|ol|optgroup|option|p|param|section|source|title|summary|table|tbody|td|tfoot|th|thead|title|tr|track|ul)(?:\s|[/]?[>]|$)""";
            ignoreCase = true;
        },
        regex {
            expression = "^(?:``openTag``|``closeTag``)\\s*$";
            ignoreCase = true;
        }
    ];
    
    value regexHtmlBlockCloses = [
        regex("."), // dummy for 0
        regex {
            expression = "</(?:script|pre|style)>";
            ignoreCase = true;
        },
        regex("-->"),
        regex("""\?>"""),
        regex(">"),
        regex("""\]\]>""")
    ];
    
    value spacesPerTab = 4;
    
    function spacesToTab(Integer column) => spacesPerTab - (column % spacesPerTab);
    
    variable Boolean allClosed;
    
    variable Boolean blank;
    
    variable Integer column;
    
    variable String currentLine;
    
    variable Document document;
    
    variable Integer indent;
    
    variable Boolean indented;
    
    InlineParser inlineParser;
    
    variable Integer lastLineLength;
    
    variable Node lastMatchedContainer;
    
    variable Integer lineNumber;
    
    variable Integer nextNonspace;
    
    variable Integer nextNonspaceColumn;
    
    variable Integer offset;
    
    variable Node? oldTip;
    
    ParseOptions options;
    
    variable Boolean partiallyConsumedTab;
    
    MutableMap<String, Reference> references;
    
    variable Node tip;
    
    shared new(ParseOptions options = ParseOptions()) {
        document = Document();
        tip = document;
        oldTip = document;
        currentLine = "";
        lineNumber = 0;
        offset = 0;
        column = 0;
        nextNonspace = 0;
        nextNonspaceColumn = 0;
        indent = 0;
        indented = false;
        blank = false;
        partiallyConsumedTab = false;
        allClosed = true;
        lastMatchedContainer = document;
        references = HashMap<String, Reference>();
        lastLineLength = 0;
        inlineParser = InlineParser();
        this.options = options;
    }
    
    // Parse a list marker and return data on the marker (type,
    // start, delimiter, bullet character, padding) or null.
    ListData? parseListMarker(Node container) {
        value rest = currentLine.substring(nextNonspace);
        ListData data;
        Integer matchLength;
        
        if (exists match = regex(regexBulletListMarker).find(rest),
            exists bulletCharacter = match.matched.first) {
            data = ListData {
                bulletCharacter = bulletCharacter;
                markerOffset = indent;
                tight = true;
                type = "bullet";
            };
            matchLength = match.matched.size;
        } else if (exists match = regex(regexOrderedListMarker).find(rest),
            exists startString = match.groups[0],
            is Integer start = Integer.parse(startString),
            exists delimiter = match.groups[1],
            container.nodeType != NodeType.paragraph || start == 1) {
            data = ListData {
                delimiter = delimiter;
                markerOffset = indent;
                start = start;
                tight = true;
                type = "ordered";
            };
            matchLength = match.matched.size;
        } else {
            return null;
        }
        
        // make sure we have spaces after
        value nextCharacter = currentLine[nextNonspace + matchLength];
        
        if (exists nextCharacter, nextCharacter != '\t' && nextCharacter != ' ') {
            return null;
        }
        
        // if it interrupts paragraph, make sure first line isn't blank
        if (container.nodeType == NodeType.paragraph
            && !regex(regexNonSpace)
                .test(currentLine.substring(nextNonspace + matchLength))) {
            return null;
        }
        
        // we've got a match! advance offset and calculate padding
        advanceNextNonspace(); // to start of marker
        advanceOffset(matchLength, true); // to end of marker
        
        variable Integer spacesStartColumn = column;
        variable Integer spacesStartOffset = offset;
        
        advanceOffset(1, true);
        
        while (column - spacesStartColumn < 5
            && peek(currentLine, offset, isSpaceOrTab)) {
            advanceOffset(1, true);
        }
        
        value spacesAfterMarker = column - spacesStartColumn;
        
        if (spacesAfterMarker >= 5
                || spacesAfterMarker < 1
                || !currentLine[offset] exists) {
            data.padding = matchLength + 1;
            column = spacesStartColumn;
            offset = spacesStartOffset;
            if (peek(currentLine, offset, isSpaceOrTab)) {
                advanceOffset(1, true);
            }
        } else {
            data.padding = matchLength + spacesAfterMarker;
        }
        
        return data;
    }
    
    function block(Node node)
        => switch (node.nodeType)
            case (NodeType.blockQuote) object satisfies Block {
                shared actual Boolean acceptsLines = false;
                
                shared actual Boolean canContain(NodeType type) => type != NodeType.item;
                
                shared actual Continuation continuation {
                    if (!indented && peek(currentLine, nextNonspace, '>'.equals)) {
                        advanceNextNonspace();
                        advanceOffset(1, false);
                        if (peek(currentLine, offset, isSpaceOrTab)) {
                            advanceOffset(1, true);
                        }
                        
                        return Continuation.matched;
                    } else {
                        return Continuation.notMatched;
                    }
                }
                
                shared actual void finalize() {}
            }
            case (NodeType.codeBlock) object satisfies Block {
                shared actual Boolean acceptsLines = true;
                
                shared actual Boolean canContain(NodeType type) => false;
                
                shared actual Continuation continuation {
                    if (node.fenced) { // fenced
                        if (indent <= 3,
                                exists fenceCharacter = node.fenceCharacter,
                                peek(currentLine, nextNonspace, fenceCharacter.equals),
                                exists match = regex(regexClosingCodeFence)
                                    .find(currentLine.substring(nextNonspace)),
                                match.matched.size >= node.fenceLength) {
                            // closing fence - we're at end of line, so we can return
                            outer.finalize(node, lineNumber);
                            
                            return Continuation.nextLine;
                        } else {
                            // skip optional spaces of fence offset
                            variable value i = node.fenceOffset;
                            
                            while (i > 0 && peek(currentLine, offset, isSpaceOrTab)) {
                                advanceOffset(1, true);
                                i--;
                            }
                        }
                    } else { // indented
                        if (indent >= codeIndent) {
                            advanceOffset(codeIndent, true);
                        } else if (blank) {
                            advanceNextNonspace();
                        } else {
                            return Continuation.notMatched;
                        }
                    }
                    
                    return Continuation.matched;
                }
                
                shared actual void finalize() {
                    if (node.fenced) { // fenced
                        // first line becomes info string
                        value content = node.stringContent?.string else "";
                        value newlinePosition = content.indexOf("\n");
                        
                        node.info = unescapeString(content.substring(0, newlinePosition).trimmed);
                        node.literal = content.substring(newlinePosition + 1);
                    } else { // indented
                        // Regex is used below, too.
                        node.literal
                            = regex("(\n *)+$").replace(node.stringContent?.string else "", "\n");
                    }
                    
                    node.clearStringContent(); // allow GC (carryover from JS)
                }
            }
            case (NodeType.document) object satisfies Block {
                shared actual Boolean acceptsLines = false;
                
                shared actual Boolean canContain(NodeType type) => type != NodeType.item;
                
                shared actual Continuation continuation
                    => Continuation.matched;
                
                shared actual void finalize() {}
            }
            case (NodeType.heading) object satisfies Block {
                shared actual Boolean acceptsLines = false;
                
                shared actual Boolean canContain(NodeType type) => false;
                
                // A heading can never contain multiple lines, so fail to match:
                shared actual Continuation continuation
                    => Continuation.notMatched;
                
                shared actual void finalize() {}
            }
            case (NodeType.htmlBlock) object satisfies Block {
                shared actual Boolean acceptsLines = true;
                
                shared actual Boolean canContain(NodeType type) => false;
                
                shared actual Continuation continuation
                    => (blank && (node.htmlBlockType == 6 || node.htmlBlockType == 7))
                        then Continuation.notMatched else Continuation.matched;
                
                shared actual void finalize() {
                    node.literal = regex("(\n *)+$").replace(node.stringContent?.string else "", "");
                    node.clearStringContent();
                }
            }
            case (NodeType.item) object satisfies Block {
                shared actual Boolean acceptsLines = false;
                
                shared actual Boolean canContain(NodeType type) => type != NodeType.item;
                
                shared actual Continuation continuation {
                    if (blank) {
                        if (!node.firstChild exists) {
                            // Blank line after empty list item
                            return Continuation.notMatched;
                        } else {
                            advanceNextNonspace();
                        }
                    } else if (indent >= node.listMarkerOffset + node.listPadding) {
                        advanceOffset(node.listMarkerOffset + node.listPadding, true);
                    } else {
                        return Continuation.notMatched;
                    }
                    
                    return Continuation.matched;
                }
                
                shared actual void finalize() {}
            }
            case (NodeType.list) object satisfies Block {
                shared actual Boolean acceptsLines = false;
                
                shared actual Boolean canContain(NodeType type) => type == NodeType.item;
                
                shared actual Continuation continuation
                    => Continuation.matched;
                
                shared actual void finalize() {
                    variable value child = node.firstChild;
                    
                    while (exists item = child) {
                        // check for non-final list item ending with blank line:
                        if (endsWithBlankLine(item) && item.next exists) {
                            node.listData.tight = false;
                            break;
                        }
                        
                        // recurse into children of list item, to see if there are
                        // spaces between any of them:
                        variable value grandchild = item.firstChild;
                        
                        while (exists subItem = grandchild) {
                            if (endsWithBlankLine(subItem)
                                    && (item.next exists || subItem.next exists)) {
                                node.listData.tight = false;
                                break;
                            }
                            
                            grandchild = subItem.next;
                        }
                        
                        child = item.next;
                    }
                }
            }
            case (NodeType.paragraph) object satisfies Block {
                shared actual Boolean acceptsLines = true;
                
                shared actual Boolean canContain(NodeType type) => false;
                
                shared actual Continuation continuation
                    => blank then Continuation.notMatched else Continuation.matched;
                
                shared actual void finalize() {
                    variable Integer position = 0;
                    variable Boolean hasReferenceDefinitions = false;
                    
                    // try parsing the beginning as link reference definitions:
                    while (exists stringContent = node.stringContent?.string,
                            peek(stringContent.string, 0, '['.equals),
                            (position = inlineParser
                                .parseReference(stringContent, references)) > 0) {
                        node.setStringContent(stringContent.substring(position));
                        hasReferenceDefinitions = true;
                    }
                    
                    if (hasReferenceDefinitions,
                            exists stringContent = node.stringContent?.string,
                            isBlank(stringContent)) {
                        node.unlink();
                    }
                }
            }
            case (NodeType.code | NodeType.emphasis | NodeType.htmlInline | NodeType.image
                    | NodeType.lineBreak | NodeType.link | NodeType.softBreak | NodeType.specialLink
                    | NodeType.strong | NodeType.text | NodeType.thematicBreak)
                    object satisfies Block {
                shared actual Boolean acceptsLines => false;
                
                shared actual Boolean canContain(NodeType type) => false;
                
                shared actual Continuation continuation
                    => Continuation.notMatched;
                
                shared actual void finalize() {}
            };
    
    value blockStarts => [
        // Block quote
        (Anything _) {
            if (!indented && peek(currentLine, nextNonspace, '>'.equals)) {
                advanceNextNonspace();
                advanceOffset(1, false);
                // optional following space
                if (peek(currentLine, offset, isSpaceOrTab)) {
                    advanceOffset(1, true);
                }
                closeUnmatchedBlocks();
                addChild(NodeType.blockQuote, nextNonspace);
                return BlockStatus.matchedContainer;
            } else {
                return BlockStatus.noMatch;
            }
        },
        
        // ATX heading
        (Anything _) {
            if (!indented,
                    exists match = regex(regexAtxHeadingMarker)
                        .find(currentLine.substring(nextNonspace))) {
                advanceNextNonspace();
                advanceOffset(match.matched.size, false);
                closeUnmatchedBlocks();
                
                value container = addChild(NodeType.heading, nextNonspace);
                container.level = match.matched.trimmed.size; // number of #s
                // remove trailing ###s:
                container.setStringContent(
                    regex("^[ \\t]*#+[ \\t]*$").replace(
                        regex("[ \\t]+#+[ \\t]*$").replace(
                            currentLine.substring(offset),
                            ""),
                        "")
                    );
                advanceOffset(currentLine.size - offset, false);
                
                return BlockStatus.matchedLeaf;
            } else {
                return BlockStatus.noMatch;
            }
        },
        
        // Fenced code block
        (Anything _) {
            if (!indented,
                    exists match = regex(regexCodeFence)
                        .find(currentLine.substring(nextNonspace)),
                    exists fenceCharacter = match.matched.first) {
                closeUnmatchedBlocks();
                
                value fenceLength = match.matched.size;
                value container = addChild(NodeType.codeBlock, nextNonspace);
                container.fenced = true;
                container.fenceLength = fenceLength;
                container.fenceCharacter = fenceCharacter;
                container.fenceOffset = indent;
                
                advanceNextNonspace();
                advanceOffset(fenceLength, false);
                
                return BlockStatus.matchedLeaf;
            } else {
                return BlockStatus.noMatch;
            }
        },
        
        // HTML block
        (Node container) {
            if (!indented && peek(currentLine, nextNonspace, '<'.equals)) {
                value string = currentLine.substring(nextNonspace);
                
                for (blockType in 1..7) {
                    if (exists regexHtmlBlockOpen = regexHtmlBlockOpens[blockType],
                            regexHtmlBlockOpen.test(string),
                            (blockType < 7 || container.nodeType != NodeType.paragraph)) {
                        closeUnmatchedBlocks();
                        // We don't adjust offset;
                        // spaces are part of the HTML block:
                        value block = addChild(NodeType.htmlBlock, offset);
                        
                        block.htmlBlockType = blockType;
                        
                        return BlockStatus.matchedLeaf;
                    }
                }
            }
            
            return BlockStatus.noMatch;
        },
        
        // Setext heading
        (Node container) {
            if (!indented,
                    container.nodeType == NodeType.paragraph,
                    exists match = regex(regexSetextHeadingLine)
                        .find(currentLine.substring(nextNonspace))) {
                closeUnmatchedBlocks();
                
                value heading = Node(NodeType.heading, container.sourcePos);
                
                heading.level = match.matched.startsWith("=") then 1 else 2;
                heading.stringContent = container.stringContent;
                
                container.insertAfter(heading);
                container.unlink();
                
                tip = heading;
                advanceOffset(currentLine.size - offset, false);
                
                return BlockStatus.matchedLeaf;
            } else {
                return BlockStatus.noMatch;
            }
        },
        
        // thematic break
        (Anything _) {
            if (!indented
                    && regex(regexThematicBreak)
                        .test(currentLine.substring(nextNonspace))) {
                closeUnmatchedBlocks();
                addChild(NodeType.thematicBreak, nextNonspace);
                advanceOffset(currentLine.size - offset, false);
                return BlockStatus.matchedLeaf;
            } else {
                return BlockStatus.noMatch;
            }
        },
        
        // list item
        (Node container) {
            if (!indented || container.nodeType == NodeType.list,
                    exists data = parseListMarker(container)) {
                closeUnmatchedBlocks();
                
                // add the list if needed
                if (tip.nodeType != NodeType.list
                        || !data.sameType(container.listData)) {
                    addChild(NodeType.list, nextNonspace).listData = data;
                }
                
                // add the list item
                addChild(NodeType.item, nextNonspace).listData = data;
                
                return BlockStatus.matchedContainer;
            } else {
                return BlockStatus.noMatch;
            }
        },
        
        // indented code block
        (Anything _) {
            if (indented
                    && tip.nodeType != NodeType.paragraph
                    && !blank) {
                // indented code
                advanceOffset(codeIndent, true);
                closeUnmatchedBlocks();
                addChild(NodeType.codeBlock, offset);
                return BlockStatus.matchedLeaf;
            } else {
                return BlockStatus.noMatch;
            }
        }
    ];
    
    shared Document parse(String input) {
        document = Document();
        tip = document;
        references.clear();
        lineNumber = 0;
        lastLineLength = 0;
        offset = 0;
        column = 0;
        lastMatchedContainer = document;
        currentLine = "";
        
        if (options.time) {
            timer.start("preparing input");
        }
        
        // TODO: May not split properly when line terminator is \r.
        value lines = input.endsWith("\n") then input.lines.exceptLast else input.lines;
        
        if (options.time) {
            timer.end("preparing input");
            timer.start("block parsing");
        }
        
        lines.each(incorporateLine);
        
        while (tip != document) {
            finalize(tip, lines.size);
        }
        
        if (options.time) {
            timer.end("block parsing");
            timer.start("inline parsing");
        }
        
        processInlines(document);
        
        if (options.time) {
            timer.end("inline parsing");
        }
        
        return document;
    }
    
    void advanceNextNonspace() {
        offset = nextNonspace;
        column = nextNonspaceColumn;
        partiallyConsumedTab = false;
    }
    
    void advanceOffset(variable Integer count, Boolean columns) {
        while (count > 0) {
            value character = currentLine[offset];
            
            if (!exists character) {
                break;
            }
            
            if (character == '\t') {
                value charsToTab = spacesToTab(column);
                
                if (columns) {
                    partiallyConsumedTab = charsToTab > count;
                    value charsToAdvance = charsToTab > count then count else charsToTab;
                    column += charsToAdvance;
                    offset += partiallyConsumedTab then 0 else 1;
                    count -= charsToAdvance;
                } else {
                    partiallyConsumedTab = false;
                    column += charsToTab;
                    offset++;
                    count--;
                }
            } else {
                partiallyConsumedTab = false;
                offset++;
                column++; // assume ascii; block starts are ascii
                count--;
            }
        }
    }
    
    Node addChild(NodeType type, Integer offset) {
        while (!block(tip).canContain(type)) {
            finalize(tip, lineNumber - 1);
        }
        
        value newBlock = Node(type, SourcePos(SourceLoc(lineNumber, offset + 1)));
        
        newBlock.stringContent = StringBuilder();
        
        tip.appendChild(newBlock);
        tip = newBlock;
        
        return newBlock;
    }
    
    void addLine() {
        if (partiallyConsumedTab) {
            offset++; // skip over tab
            
            // add space characters:
            value charsToTab = spacesToTab(column);
            
            tip.appendStringContent(" ".repeat(charsToTab));
        }
        
        tip.appendStringContent(currentLine.substring(offset));
        tip.appendStringContent("\n");
    }
    
    void closeUnmatchedBlocks() {
        if (!allClosed) {
            // finalize any blocks not matched
            while (exists oldTip = this.oldTip, oldTip != lastMatchedContainer) {
                value parent = oldTip.parent;
                
                finalize(oldTip, lineNumber - 1);
                
                this.oldTip = parent;
            }
            
            allClosed = true;
        }
    }
    
    void finalize(Node block, Integer lineNumber) {
        value parent = block.parent;
        
        block.open = false;
        
        if (exists sourcePos = block.sourcePos) {
            sourcePos.end = SourceLoc(lineNumber, lastLineLength);
        }
        
        this.block(block).finalize();
        
        if (exists parent) {
            tip = parent;
        }
    }
    
    void findNextNonspace() {
        variable value nextNonspace = offset;
        variable value nextNonspaceColumn = this.column;
        
        while (exists character = currentLine[nextNonspace]) {
            if (character == ' ') {
                nextNonspace++;
                nextNonspaceColumn++;
            } else if (character == '\t') {
                nextNonspace++;
                nextNonspaceColumn += spacesToTab(nextNonspaceColumn);
            } else {
                break;
            }
        }
        
        value character = currentLine[nextNonspace];
        
        blank = if (exists character) then (character == '\n' || character == '\r') else true;
        this.nextNonspace = nextNonspace;
        this.nextNonspaceColumn = nextNonspaceColumn;
        indent = nextNonspaceColumn - column;
        indented = indent >= codeIndent;
    }
    
    void incorporateLine(String line) {
        variable Node container = document;
        oldTip = tip;
        offset = 0;
        column = 0;
        blank = false;
        partiallyConsumedTab = false;
        lineNumber++;
        
        // replace NUL characters for security
        currentLine = line.replace("\{NULL}", "\{REPLACEMENT CHARACTER}");
        
        // For each containing block, try to parse the associated line start.
        // Bail out on failure: container will point to the last matching block.
        // Set all_matched to false if not all containers match.
        while (exists lastChild = container.lastChild, lastChild.open) {
            findNextNonspace();
            
            switch (block(lastChild).continuation)
            case (Continuation.matched) {
                // we've matched, keep going
                container = lastChild;
            }
            case (Continuation.notMatched) {
                // we've failed to match a block, stay on the last matching block
                break;
            }
            case (Continuation.nextLine) {
                // we've hit end of line for fenced code close and can return
                lastLineLength = currentLine.size;
                return;
            }
        }
        
        allClosed = if (exists oldTip = oldTip) then container == oldTip else false;
        lastMatchedContainer = container;
        
        variable value matchedLeaf = container.nodeType != NodeType.paragraph
                && block(container).acceptsLines;
        
        // Unless last matched container is a code block, try new container starts,
        // adding children to the last matched container:
        while (!matchedLeaf) {
            findNextNonspace();
            
            for (blockStart in blockStarts) {
                switch (blockStart(container))
                case (BlockStatus.noMatch) {
                    // Keep going.
                }
                case (BlockStatus.matchedContainer) {
                    container = tip;
                    break;
                }
                case (BlockStatus.matchedLeaf) {
                    container = tip;
                    matchedLeaf = true;
                    break;
                }
            }
            else { // Nothing matched
                advanceNextNonspace();
                break;
            }
        }
        
        // What remains at the offset is a text line.  Add the text to the
        // appropriate container.
        
        // First check for a lazy paragraph continuation:
        if (!allClosed && !blank && tip.nodeType == NodeType.paragraph) {
            addLine();
        } else { // not a lazy continuation
            // finalize any blocks not matched
            closeUnmatchedBlocks();
            
            if (exists child = container.lastChild, blank) {
                child.lastLineBlank = true;
            }
            
            // Block quote lines are never blank as they start with >
            // and we don't count blanks in fenced code for purposes of tight/loose
            // lists or breaking out of lists.  We also don't set _lastLineBlank
            // on an empty list item, or if we just closed a fenced block.
            value lastLineBlank = blank
                && !(container.nodeType == NodeType.blockQuote
                    || (container.nodeType == NodeType.codeBlock && container.fenced)
                    || (container.nodeType == NodeType.item
                        && !container.firstChild exists
                        && (container.sourcePos?.start?.line else 0) == lineNumber));
            
            // propagate lastLineBlank up through parents:
            variable Node? cont = container;
            while (exists cont2 = cont) {
                cont2.lastLineBlank = lastLineBlank;
                cont = cont2.parent;
            }
            
            if (block(container).acceptsLines) {
                addLine();
                // if HtmlBlock, check for end condition
                if (container.nodeType == NodeType.htmlBlock
                    && container.htmlBlockType >= 1
                    && container.htmlBlockType <= 5,
                    exists regexHtmlBlockClose = regexHtmlBlockCloses[container.htmlBlockType],
                    regexHtmlBlockClose.test(currentLine.substring(offset))) {
                    finalize(container, lineNumber);
                }
            } else if (offset < line.size && !blank) {
                // create paragraph container for line
                addChild(NodeType.paragraph, offset);
                advanceNextNonspace();
                addLine();
            }
        }
        
        lastLineLength = line.size;
    }
    
    void processInlines(Node block) {
        inlineParser.references = references;
        inlineParser.options = options;
        
        for ([entering, node] in block) {
            if (!entering
                    && (node.nodeType == NodeType.paragraph || node.nodeType == NodeType.heading)) {
                inlineParser.parse(node);
            }
        }
    }
}
