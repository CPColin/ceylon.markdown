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

"The various types of [[Node]]s that the [[Parser]] can generate."
shared class NodeType
        of blockQuote | code | codeBlock | document | emphasis | heading | htmlBlock | htmlInline
        | image | item | lineBreak | link | list | paragraph | softBreak | specialLink | strong
        | text | thematicBreak {
    shared String commonmarkJsType;
    
    shared Boolean container;
    
    shared new blockQuote {
        commonmarkJsType = "block_quote";
        container = true;
    }
    
    shared new code {
        commonmarkJsType = "code";
        container = false;
    }
    
    shared new codeBlock {
        commonmarkJsType = "code_block";
        container = false;
    }
    
    shared new document {
        commonmarkJsType = "document";
        container = true;
    }
    
    shared new emphasis {
        commonmarkJsType = "emph";
        container = true;
    }
    
    shared new heading {
        commonmarkJsType = "heading";
        container = true;
    }
    
    shared new htmlBlock {
        commonmarkJsType = "html_block";
        container = false;
    }
    
    shared new htmlInline {
        commonmarkJsType = "html_inline";
        container = false;
    }
    
    shared new image {
        commonmarkJsType = "image";
        container = true;
    }
    
    shared new item {
        commonmarkJsType = "item";
        container = true;
    }
    
    shared new lineBreak {
        commonmarkJsType = "linebreak";
        container = false;
    }
    
    shared new link {
        commonmarkJsType = "link";
        container = true;
    }
    
    shared new list {
        commonmarkJsType = "list";
        container = true;
    }
    
    shared new paragraph {
        commonmarkJsType = "paragraph";
        container = true;
    }
    
    shared new softBreak {
        commonmarkJsType = "softbreak";
        container = false;
    }
    
    shared new specialLink {
        commonmarkJsType = "special_link";
        container = false;
    }
    
    shared new strong {
        commonmarkJsType = "strong";
        container = true;
    }
    
    shared new text {
        commonmarkJsType = "text";
        container = false;
    }
    
    shared new thematicBreak {
        commonmarkJsType = "thematic_break";
        container = false;
    }
    
    string = commonmarkJsType;
}
