import ceylon.markdown.parser {
    ListData,
    Node,
    NodeType
}
import ceylon.markdown.renderer {
    elideInTightList
}
import ceylon.test {
    assertEquals,
    parameters,
    test
}

{Boolean?*} testElideInTightListParameters = {
    null,
    false,
    true
};

[Node, Node] createTestListAndParagraph(Boolean? tight) {
    value list = Node(NodeType.list);
    
    list.listData = ListData {
        tight = tight;
    };
    
    value item = Node(NodeType.item);
    
    list.appendChild(item);
    
    value paragraph = Node(NodeType.paragraph);
    
    item.appendChild(paragraph);
    
    value text = Node(NodeType.text);
    
    text.literal = "text";
    
    paragraph.appendChild(text);
    
    return [list, paragraph];
}

Node createTestList(Boolean? tight) => createTestListAndParagraph(tight).first;

Node createTestParagraph(Boolean? tight) => createTestListAndParagraph(tight).last;

test
parameters(`value testElideInTightListParameters`)
void testElideInTightList(Boolean? tight) {
    value paragraph = createTestParagraph(tight);
    
    assertEquals(elideInTightList(paragraph), tight else false);
}
