import ceylon.markdown.parser {
    Node
}
import ceylon.regex {
    regex
}

shared String headingId(String headingText) {
    function replacement(String match) {
        if (match == "-") {
            // Convert each hyphen into an underscore.
            return "_";
        } else if (exists character = match.first, character.whitespace) {
            // Convert each run of whitespace into an underscore.
            return "_";
        } else {
            // Drop all non-word characters.
            return "";
        }
    }
    
    return regex {
        expression = """-|\s+|[^\w\s]+""";
        global = true;
    }.replace(headingText.lowercased, replacement);
}

String? headingIdAttribute(RenderOptions options)(Node node)
        //=> if (options.linkHeadings) then headingId(textContent(node)) else null;
        => null;

shared String? languageAttribute(RenderOptions options)(Node node)
        => if (exists language = node.info?.split(' '.equals)?.first, !language.empty)
        then "language-``language``"
        else (if (exists defaultLanguage = options.defaultLanguage)
            then "language-``defaultLanguage``"
            else null);

Integer? listStart(Node node)
        => if (exists start = node.listStart, start != 1) then start else null;

String? nonemptyTitle(Node node)
        => let (title = node.title else "")
            if (title.empty) then null else title;

Boolean potentiallyUnsafe(String url) {
    value regexSafeDataProtocol = regex {
        expression = """^data:image\/(?:png|gif|jpeg|webp)""";
        ignoreCase = true;
    };
    
    value regexUnsafeProtocol = regex {
        expression = "^javascript:|vbscript:|file:|data:";
        ignoreCase = true;
    };
    
    return regexUnsafeProtocol.test(url) && !regexSafeDataProtocol.test(url);
}

String rawHtmlOmitted(RenderOptions options)(Node node)
        => options.safe then "<!-- raw HTML omitted -->" else (node.literal else "");

String safeDestination(RenderOptions options)(Node node)
        => let (destination = node.destination else "")
            if (options.safe && potentiallyUnsafe(destination)) then "" else destination;

[<String->String>*] sourcePosAttribute(RenderOptions options)(Node node)
        => if (exists sourcePos = node.sourcePos, options.sourcePos)
        then ["data-sourcepos"->sourcePos.string] else empty;

"Collects and returns all text content contained in the given [[root]] and its children."
shared String textContent(Node root) {
    value stringBuilder = StringBuilder();
    
    for ([entering, node] in root) {
        if (entering, exists literal = node.literal) {
            stringBuilder.append(literal);
        }
    }
    
    return stringBuilder.string;
}
