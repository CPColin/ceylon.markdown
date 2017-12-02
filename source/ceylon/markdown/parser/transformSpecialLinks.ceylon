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
