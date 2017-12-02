// Ported from commonmark.js/lib/render/html.js

import ceylon.markdown.parser {
    Node,
    NodeType
}

shared class RawHtmlRenderer(RenderOptions options = RenderOptions()) {
    value buffer = StringBuilder();
    
    variable value disableTags = 0;
    
    "Concatenates a literal string to the [[buffer]], without escaping it."
    void literal(String string) {
        buffer.append(string);
    }
    
    "Outputs a newline character, if the [[buffer]] is not empty and the last character in it isn't
     already a newline."
    void newline() {
        if (exists character = buffer.last, character != '\n') {
            buffer.append("\n");
        }
    }
    
    "Concatenates a string to the [[buffer]], after escaping it."
    void output(String string) {
        literal(escapeHtml(string, false));
    }
    
    value headingIdAttribute => package.headingIdAttribute(options);
    
    value languageAttribute => package.languageAttribute(options);
    
    value rawHtmlOmitted => package.rawHtmlOmitted(options);
    
    value safeDestination => package.safeDestination(options);
    
    value sourcePosAttribute => package.sourcePosAttribute(options);
    
    "Helper function to produce an HTML tag."
    void tag(String name, {<String -> String?>*} attributes = empty, Boolean selfClosing = false) {
        if (disableTags > 0) {
            return;
        }
        
        buffer.append("<``name``");
        
        for (attributeName -> attributeValue in attributes) {
            if (exists attributeValue) {
                buffer.append(" ``attributeName``=\"``attributeValue``\"");
            }
        }
        
        if (selfClosing) {
            buffer.append(" /");
        }
        
        buffer.append(">");
    }
    
    // Node rendering methods
    
    void text(Node node) {
        output(node.literal else "");
    }
    
    void softBreak() {
        literal(options.softBreak);
    }
    
    void lineBreak() {
        tag("br", empty, true);
        newline();
    }
    
    void link(Node node, Boolean entering) {
        if (entering) {
            tag("a", sourcePosAttribute(node).chain {
                "href" -> escapeHtml(safeDestination(node), true),
                "title" -> (if (exists title = nonemptyTitle(node))
                    then escapeHtml(title, true) else null)
            });
        } else {
            tag("/a");
        }
    }
    
    void image(Node node, Boolean entering) {
        if (entering) {
            if (disableTags == 0) {
                literal("<img src=\"``escapeHtml(safeDestination(node), true)``\" alt=\"");
            }
            
            disableTags++;
        } else {
            disableTags--;
            
            if (disableTags == 0) {
                if (exists title = node.title, !title.empty) {
                    literal("\" title=\"``escapeHtml(title, true)``");
                }
                
                literal("\" />");
            }
        }
    }
    
    void emphasis(Node node, Boolean entering) {
        tag(entering then "em" else "/em");
    }
    
    void strong(Node node, Boolean entering) {
        tag(entering then "strong" else "/strong");
    }
    
    void paragraph(Node node, Boolean entering) {
        if (elideInTightList(node)) {
            return;
        }
        
        if (entering) {
            newline();
            tag("p", sourcePosAttribute(node));
        } else {
            tag("/p");
            newline();
        }
    }
    
    void heading(Node node, Boolean entering) {
        value tagName = "h``node.level else 0``";
        
        if (entering) {
            newline();
            tag(tagName, sourcePosAttribute(node).chain { "id" -> headingIdAttribute(node) });
            
            if (options.linkHeadings) {
                tag("a", { "href" -> "#``headingId(textContent(node))``" });
            }
        } else {
            if (options.linkHeadings) {
                tag ("/a");
            }
            
            tag("/``tagName``");
            newline();
        }
    }
    
    void code(Node node, Boolean entering) {
        tag("code");
        output(node.literal else "");
        tag("/code");
    }
    
    void codeBlock(Node node) {
        newline();
        tag("pre");
        tag("code", sourcePosAttribute(node).chain { "class" -> languageAttribute(node) });
        output(node.literal else "");
        tag("/code");
        tag("/pre");
        newline();
    }
    
    void thematicBreak(Node node) {
        newline();
        tag("hr", sourcePosAttribute(node), true);
        newline();
    }
    
    void blockQuote(Node node, Boolean entering) {
        if (entering) {
            newline();
            tag("blockquote", sourcePosAttribute(node));
            newline();
        } else {
            newline();
            tag("/blockquote");
            newline();
        }
    }
    
    void list(Node node, Boolean entering) {
        value tagName = (node.listType else "") == "bullet" then "ul" else "ol";
        
        if (entering) {
            newline();
            tag(tagName, sourcePosAttribute(node).chain { "start" -> listStart(node)?.string });
            newline();
        } else {
            newline();
            tag("/``tagName``");
            newline();
        }
    }
    
    void item(Node node, Boolean entering) {
        if (entering) {
            tag("li", sourcePosAttribute(node));
        } else {
            tag("/li");
            newline();
        }
    }
    
    void htmlInline(Node node) {
        literal(rawHtmlOmitted(node));
    }
    
    void htmlBlock(Node node) {
        newline();
        htmlInline(node);
        newline();
    }
    
    void specialLink(Node node) {
        literal(package.specialLink(node));
    }
    
    function renderFunction(Node node)
        => switch (node.nodeType)
            case (NodeType.blockQuote) blockQuote
            case (NodeType.code) code
            case (NodeType.codeBlock) codeBlock
            case (NodeType.document) (() {}) // No-op
            case (NodeType.emphasis) emphasis
            case (NodeType.heading) heading
            case (NodeType.htmlBlock) htmlBlock
            case (NodeType.htmlInline) htmlInline
            case (NodeType.image) image
            case (NodeType.item) item
            case (NodeType.lineBreak) lineBreak
            case (NodeType.link) link
            case (NodeType.list) list
            case (NodeType.paragraph) paragraph
            case (NodeType.softBreak) softBreak
            case (NodeType.specialLink) specialLink
            case (NodeType.strong) strong
            case (NodeType.text) text
            case (NodeType.thematicBreak) thematicBreak;
    
    shared String render(Node root) {
        buffer.clear();
        
        for ([entering, node] in root) {
            value renderFunction = this.renderFunction(node);
            
            // Didn't need "else" on JVM, for some reason.
            if (is Anything() renderFunction) {
                renderFunction();
            }
            else if (is Anything(Node) renderFunction) {
                renderFunction(node);
            }
            else {
                renderFunction(node, entering);
            }
        }
        
        return buffer.string;
    }
}
