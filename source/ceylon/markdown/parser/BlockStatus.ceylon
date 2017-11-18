// Ported from commonmark.js/lib/blocks.js::blockStarts

shared class BlockStatus of noMatch | matchedContainer | matchedLeaf {
    shared new noMatch {}
    
    shared new matchedContainer {}
    
    shared new matchedLeaf {}
}
