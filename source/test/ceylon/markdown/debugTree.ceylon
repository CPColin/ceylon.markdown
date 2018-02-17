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
    NodeWalker
}

shared void debugTree(Node|INode root) {
    function parentCount(Node|INode node) {
        variable Integer count = 0;
        variable Node|INode current = node;
        
        while (exists parent = current.parent) {
            count++;
            current = parent;
        }
        
        return count;
    }
    
    void printNode(Node|INode node) {
        print("``"  ".repeat(parentCount(node))````debugNode(node)``");
    }
    
    if (is Node root) {
        for ([entering, node] in root) {
            if (entering || !node.firstChild exists) {
                printNode(node);
            }
        }
    }
    else {
        for ([entering, node] in NodeWalker(root)) {
            if (entering || !node.firstChild exists) {
                printNode(node);
            }
        }
    }
    
    print("---");
}