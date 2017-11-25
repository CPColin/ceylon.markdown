import ceylon.collection {
    LinkedList,
    MutableList
}
import ceylon.html {
    A,
    Blockquote,
    Br,
    CharacterData,
    Code,
    Em,
    FlowCategory,
    H1,
    H2,
    H3,
    H4,
    H5,
    H6,
    Hr,
    HtmlNode=Node,
    Img,
    Li,
    Ol,
    P,
    PhrasingCategory,
    Pre,
    Raw,
    Strong,
    Ul
}
import ceylon.markdown.parser {
    AstNode=Node,
    Document,
    NodeType,
    Parser
}

shared class CeylonHtmlRenderer(RenderOptions options = RenderOptions()) {
    shared alias Element => CharacterData|HtmlNode;
    
    function narrow<Type>({Element*} children) => children.narrow<CharacterData|<HtmlNode&Type>>();
    
    value headingIdAttribute => package.headingIdAttribute(options);
    
    value languageAttribute => package.languageAttribute(options);
    
    value rawHtmlOmitted => package.rawHtmlOmitted(options);
    
    value safeDestination => package.safeDestination(options);
    
    value sourcePosAttribute => package.sourcePosAttribute(options);
    
    function text(AstNode node, Anything _ = null) => node.literal else "";
    
    function softBreak(AstNode node, Anything _ = null) => Raw(options.softBreak);
    
    function lineBreak(AstNode node, Anything _ = null) => Br();
    
    function link(AstNode node, {Element*} children)
        => A {
            attributes = sourcePosAttribute(node);
            href = safeDestination(node);
            title = nonemptyTitle(node);
            children = narrow<FlowCategory>(children);
        };
    
    function childText(AstNode node) => StringBuilder().appendAll({
        for ([entering, child] in node)
            if (entering, child.nodeType == NodeType.text)
                child.literal else ""
    }).string;
    
    function image(AstNode node, Anything _ = null)
        => Img {
            alt = childText(node);
            src = safeDestination(node);
            title = nonemptyTitle(node);
        };
    
    function emph(AstNode node, {Element*} children)
        => Em { children = narrow<PhrasingCategory>(children); };
    
    function strong(AstNode node, {Element*} children)
        => Strong { children = narrow<PhrasingCategory>(children); };
    
    function paragraph(AstNode node, {Element*} children)
        => if (exists grandparent = node.parent?.parent,
            grandparent.nodeType == NodeType.list,
            grandparent.listTight else false)
        then children // Elide Paragraph nodes in tight lists.
        else P {
            attributes = sourcePosAttribute(node);
            children = narrow<PhrasingCategory>(children);
        };
    
    function heading(AstNode node, {Element*} children) {
        value attributes = sourcePosAttribute(node);
        value wrappedChildren = options.linkHeadings
            then {
                A {
                    href = "#``headingId(textContent(node))``";
                    narrow<FlowCategory>(children)
                }
            }
            else narrow<PhrasingCategory>(children);
        
        return switch (node.level else 0)
            case (1) H1 { id = headingIdAttribute(node); attributes = attributes; children = wrappedChildren; }
            case (2) H2 { id = headingIdAttribute(node); attributes = attributes; children = wrappedChildren; }
            case (3) H3 { id = headingIdAttribute(node); attributes = attributes; children = wrappedChildren; }
            case (4) H4 { id = headingIdAttribute(node); attributes = attributes; children = wrappedChildren; }
            case (5) H5 { id = headingIdAttribute(node); attributes = attributes; children = wrappedChildren; }
            case (6) H6 { id = headingIdAttribute(node); attributes = attributes; children = wrappedChildren; }
            else "";
    }
    
    function code(AstNode node, Anything _ = null) => Code { node.literal };
    
    function codeBlock(AstNode node, Anything _ = null)
        => Pre {
            Code {
                attributes = sourcePosAttribute(node);
                clazz = languageAttribute(node);
                node.literal
            }
        };
    
    function thematicBreak(AstNode node, {Element*} children)
        => Hr {
            attributes = sourcePosAttribute(node);
        };
    
    function blockQuote(AstNode node, {Element*} children)
        => Blockquote {
            attributes = sourcePosAttribute(node);
            children = narrow<FlowCategory>(children);
        };
    
    function list(AstNode node, {Element*} children)
        => if (exists listType = node.listType, listType == "bullet")
        then Ul {
            children = children.narrow<Li>();
        }
        else Ol {
            attributes = sourcePosAttribute(node);
            children = children.narrow<Li>();
            start = listStart(node);
        };
    
    function item(AstNode node, {Element*} children)
        => Li {
            attributes = sourcePosAttribute(node);
            children = narrow<FlowCategory>(children);
        };
    
    function htmlInline(AstNode node, Anything _) => Raw(rawHtmlOmitted(node));
    
    function htmlBlock(AstNode node, Anything _) => {
        "\n",
        htmlInline(node, _),
        "\n"
    };
    
    function renderFunction(AstNode node)
        => switch (node.nodeType)
            case (NodeType.blockQuote) blockQuote
            case (NodeType.code) code
            case (NodeType.codeBlock) codeBlock
            case (NodeType.document) ((Anything node, Anything children) => empty) // No-op
            case (NodeType.emphasis) emph
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
            case (NodeType.strong) strong
            case (NodeType.text) text
            case (NodeType.thematicBreak) thematicBreak;
    
    shared Element[] render(AstNode root) {
        value stack = LinkedList<MutableList<Element>>();
        
        void renderNode(AstNode node, {Element*} children) {
            value renderFunction = this.renderFunction(node);
            value renderedNode = renderFunction(node, children);
            
            if (is Element renderedNode) {
                stack.top?.add(renderedNode);
            } else {
                stack.top?.addAll(renderedNode);
            }
        }
        
        for ([entering, node] in root) {
            if (node.isContainer) {
                if (entering) {
                    stack.push(LinkedList<Element>());
                } else {
                    value children = stack.pop();
                    
                    assert (exists children);
                    
                    if (node is Document) {
                        return children.sequence();
                    }
                    
                    renderNode(node, children);
                }
            } else {
                renderNode(node, empty);
            }
        }
        else {
            return empty;
        }
    }
}
