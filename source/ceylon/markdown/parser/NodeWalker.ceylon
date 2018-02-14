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

shared class NodeWalker<Type>(Type root)
        satisfies Iterable<[Boolean, Type]> & Iterator<[Boolean, Type]>
        given Type satisfies WalkableNode<Type> {
    variable Type? current = root;
    
    variable Boolean entering = true;
    
    shared actual Iterator<[Boolean, Type]> iterator() => NodeWalker(root);
    
    shared actual [Boolean, Type]|Finished next() {
        value current = this.current;
        value currentEntering = entering;
        
        if (!exists current) {
            return finished;
        }
        
        if (entering && current.isContainer) {
            if (exists child = current.firstChild) {
                this.current = child;
                entering = true;
            } else {
                this.current = current;
                entering = false;
            }
        } else if (current == root) {
            this.current = null;
        } else if (exists next = current.next) {
            this.current = next;
            entering = true;
        } else {
            this.current = current.parent;
            entering = false;
        }
        
        return [currentEntering, current];
    }
}
