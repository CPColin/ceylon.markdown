import ceylon.markdown.parser {
    Node
}

String debugNode(Node|INode node) {
    value literal = if (exists literal = node.literal) then literal else "";
    
    if (is Node node) {
        return "ceylon.markdown: ``node.type`` ``node.sourcePos?.string else ""`` [``literal``]";
    } else {
        return "commonmark.js: ``node.type`` ``node.sourcepos else ""`` [``literal``]";
    }
}
