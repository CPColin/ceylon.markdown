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
    WalkableNode
}

import commonmark {
    HtmlRenderer,
    Parser
}

shared dynamic INode satisfies WalkableNode<INode> {
    shared formal String onEnter;
    
    shared formal String onExit;
    
    shared formal String? sourcepos;
}

dynamic IParseOptions {
    shared formal Boolean smart;
}

dynamic IParser {
    shared formal INode parse(String markdown);
    
    shared formal IParseOptions options;
}

dynamic IRenderer {
    shared formal String render(INode node);
}

native("js") IParser commonmarkJsParser(Boolean smartOption = false) {
    dynamic {
        dynamic parser = Parser();
        
        parser.options.smart = smartOption;
        
        return parser;
    }
}

native("js") IRenderer commonmarkJsRenderer {
    dynamic {
        dynamic renderer = HtmlRenderer();
        
        return renderer;
    }
}
