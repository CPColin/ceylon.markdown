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

// Ported from commonmark.js/lib/node.js

"A specific location in the Markdown source that was rendered."
shared class SourceLoc(shared Integer line = 0, shared Integer column = 0) {
    string => "``line``:``column``";
}

"A range of locations in the Markdown source that was rendered."
shared class SourcePos(shared variable SourceLoc start = SourceLoc(),
    shared variable SourceLoc end = SourceLoc()) {
    string => "``start``-``end``";
}

"A node in the tree produced by the [[Parser]].
 
 This class is intentionally not very ceylonic, so it can continue to resemble the JavaScript code
 it was ported from. This leads to a lot of `variable` attributes that hang around for longer than
 they need to and have the potential to confuse developers who are looking to manipulate these
 objects before they are rendered."
shared class Node(shared NodeType nodeType, shared SourcePos? sourcePos = null)
        satisfies WalkableNode<Node> & Iterable<[Boolean, Node]> {
    shared actual variable String? destination = null;
    
    shared variable Character? fenceCharacter = null;
    
    shared variable Boolean fenced = false;
    
    shared variable Integer fenceLength = 0;
    
    shared variable Integer fenceOffset = 0;
    
    shared actual variable Node? firstChild = null;
    
    shared variable Integer htmlBlockType = 0;
    
    shared actual variable String? info = null;
    
    shared actual Boolean isContainer = nodeType.container;
    
    shared actual variable Node? lastChild = null;
    
    shared variable Boolean lastLineBlank = false;
    
    shared actual variable Integer? level = null;
    
    shared variable ListData listData = ListData();
    
    shared Character? listBulletCharacter => listData.bulletCharacter;
    
    shared actual String? listDelimiter => listData.delimiter;
    
    shared Integer listMarkerOffset => listData.markerOffset else 0;
    
    shared Integer listPadding => listData.padding else 0;
    
    shared actual Integer? listStart => listData.start;
    
    shared actual Boolean? listTight => listData.tight;
    
    shared actual String? listType => listData.type;
    
    shared actual variable String? literal = null;
    
    shared actual variable Node? next = null;
    
    shared variable Boolean open = true;
    
    shared actual variable Node? parent = null;
    
    shared actual variable Node? prev = null;
    
    shared variable StringBuilder? stringContent = null;
    
    shared actual variable String? title = null;
    
    shared actual String type = nodeType.commonmarkJsType;
    
    shared void appendChild(Node child) {
        child.unlink();
        child.parent = this;
        
        if (exists lastChild = this.lastChild) {
            lastChild.next = child;
            child.prev = lastChild;
            this.lastChild = child;
        } else {
            this.firstChild = child;
            this.lastChild = child;
        }
    }
    
    shared void appendStringContent(String content) {
        value stringBuilder = this.stringContent else (this.stringContent = StringBuilder());
        
        stringBuilder.append(content);
    }
    
    shared void clearStringContent() {
        if (stringContent exists) {
            stringContent = null;
        }
    }
    
    "Inserts the given [[sibling]] node after this node."
    shared void insertAfter(Node sibling) {
        sibling.unlink();
        sibling.next = this.next;
        if (exists next = sibling.next) {
            next.prev = sibling;
        }
        sibling.prev = this;
        this.next = sibling;
        sibling.parent = this.parent;
        if (exists parent = sibling.parent, !sibling.next exists) {
            parent.lastChild = sibling;
        }
    }
    
    shared actual Iterator<[Boolean, Node]> iterator() => NodeWalker(this);
    
    shared void setStringContent(String string) {
        stringContent = StringBuilder().append(string);
    }
    
    shared void unlink() {
        if (exists prev = this.prev) {
            prev.next = next;
        } else if (exists parent = this.parent) {
            parent.firstChild = next;
        }
        
        if (exists next = this.next) {
            next.prev = prev;
        } else if (exists parent = this.parent) {
            parent.lastChild = prev;
        }
        
        parent = null;
        next = null;
        prev = null;
    }
}
