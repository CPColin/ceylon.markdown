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
        commonmarkJsType = "specialLink";
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
}
