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
