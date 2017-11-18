// Ported from commonmark.js/lib/node.js

shared class NodeWalker<Type>(Type root)
        satisfies Iterable<[Boolean, Type]> & Iterator<[Boolean, Type]>
        given Type satisfies WalkableNode<Type> {
    variable Type? current = root;
    
    variable Boolean entering = true;
    
    shared actual Iterator<[Boolean, Type]> iterator() => NodeWalker(root);
    
    shared actual [Boolean, Type]|Finished next() {
        value current = this.current;
        value currentEntering = entering;
        
        if (!exists current) {
            return finished;
        }
        
        if (entering && current.isContainer) {
            if (exists child = current.firstChild) {
                this.current = child;
                entering = true;
            } else {
                this.current = current;
                entering = false;
            }
        } else if (current == root) {
            this.current = null;
        } else if (exists next = current.next) {
            this.current = next;
            entering = true;
        } else {
            this.current = current.parent;
            entering = false;
        }
        
        return [currentEntering, current];
    }
}
