import ceylon.markdown.parser {
    WalkableNode
}

import commonmark {
    HtmlRenderer,
    Parser
}

dynamic INode satisfies WalkableNode<INode> {
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
