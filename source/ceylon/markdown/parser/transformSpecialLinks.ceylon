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

"Walks the AST, starting at the given [[root]], applying the given [[transform]] operation to all
 \"special link\" nodes that are found."
shared void transformSpecialLinks(
    Node root,
    "A function that takes the [[content]] of a \"special link\" node and returns the node that
     should replace it, if appropriate, or `null`, if the original node should be left alone."
    Node? transform(
        "The text that was between the double brackets when the node was created."
        String content)) {
    for ([entering, oldNode] in root) {
        if (entering,
            oldNode.nodeType == NodeType.specialLink,
            exists content = oldNode.literal,
            exists newNode = transform(content)) {
            oldNode.insertAfter(newNode);
            oldNode.unlink();
        }
    }
}
