import ceylon.markdown.parser {
    Node
}

"A renderer that takes a tree of [[Node]] objects as input and produces the specified [[Output]]."
shared abstract class Renderer<Output>(options) {
    shared RenderOptions options;
    
    shared String?(Node) headingIdAttribute => package.headingIdAttribute(options);
    
    shared String?(Node) languageAttribute => package.languageAttribute(options);
    
    shared String(Node) rawHtmlOmitted => package.rawHtmlOmitted(options);
    
    shared String(Node) safeDestination => package.safeDestination(options);
    
    shared <String->String>[](Node) sourcePosAttribute => package.sourcePosAttribute(options);
    
    "Renders the given tree, starting at its [[root]]."
    shared formal Output render(Node root);
}
