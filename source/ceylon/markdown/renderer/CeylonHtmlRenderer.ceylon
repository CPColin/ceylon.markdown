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
    NodeType
}

"A renderer that produces a sequence of elements compatible with classes in [[module ceylon.html]]."
shared class CeylonHtmlRenderer(RenderOptions options = RenderOptions())
        extends Renderer<Element[]>(options) {
    "Alias for the type of objects that this renderer will output. These objects should be able to
     become children of most block-level elements found in [[module ceylon.html]]."
    shared alias Element => CharacterData|HtmlNode;
    
    "Alias for a single [[Element]] object or a stream of them."
    shared alias Elements => Element|{Element*};
    
    shared {<CharacterData|HtmlNode&Type>*} narrow<Type>({Element*} children)
            => children.narrow<CharacterData|<HtmlNode&Type>>();
    
    shared default Elements text(AstNode node, Anything _ = null) => node.literal else "";
    
    shared default Elements softBreak(AstNode node, Anything _ = null) => Raw(options.softBreak);
    
    shared default Elements lineBreak(AstNode node, Anything _ = null) => Br();
    
    shared default Elements link(AstNode node, {Element*} children)
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
    
    shared default Elements image(AstNode node, Anything _ = null)
        => Img {
            alt = childText(node);
            src = safeDestination(node);
            title = nonemptyTitle(node);
        };
    
    shared default Elements emphasis(AstNode node, {Element*} children)
        => Em { children = narrow<PhrasingCategory>(children); };
    
    shared default Elements strong(AstNode node, {Element*} children)
        => Strong { children = narrow<PhrasingCategory>(children); };
    
    shared default Elements paragraph(AstNode node, {Element*} children)
        => elideInTightList(node)
        then children // Elide Paragraph nodes in tight lists.
        else P {
            attributes = sourcePosAttribute(node);
            children = narrow<PhrasingCategory>(children);
        };
    
    shared default Elements heading(AstNode node, {Element*} children) {
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
    
    shared default Elements code(AstNode node, Anything _ = null) => Code { node.literal };
    
    shared default Elements codeBlock(AstNode node, Anything _ = null)
        => Pre {
            Code {
                attributes = sourcePosAttribute(node);
                clazz = languageAttribute(node);
                node.literal
            }
        };
    
    shared default Elements thematicBreak(AstNode node, {Element*} children)
        => Hr {
            attributes = sourcePosAttribute(node);
        };
    
    shared default Elements blockQuote(AstNode node, {Element*} children)
        => Blockquote {
            attributes = sourcePosAttribute(node);
            children = narrow<FlowCategory>(children);
        };
    
    shared default Elements list(AstNode node, {Element*} children)
        => if (exists listType = node.listType, listType == "bullet")
        then Ul {
            attributes = sourcePosAttribute(node);
            children = children.narrow<Li>();
        }
        else Ol {
            attributes = sourcePosAttribute(node);
            children = children.narrow<Li>();
            start = listStart(node);
        };
    
    shared default Elements item(AstNode node, {Element*} children)
        => Li {
            attributes = sourcePosAttribute(node);
            children = narrow<FlowCategory>(children);
        };
    
    shared default Elements htmlInline(AstNode node, Anything _) => Raw(rawHtmlOmitted(node));
    
    shared default Elements htmlBlock(AstNode node, Anything _) => {
        "\n",
        Raw(rawHtmlOmitted(node)),
        "\n"
    };
    
    shared default Elements specialLink(AstNode node, Anything _ = null)
            => package.specialLink(node);
    
    function renderFunction(AstNode node)
        => switch (node.nodeType)
            case (NodeType.blockQuote) blockQuote
            case (NodeType.code) code
            case (NodeType.codeBlock) codeBlock
            case (NodeType.document) ((Anything node, Anything children) => empty) // No-op
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
    
    shared actual Element[] render(AstNode root) {
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
