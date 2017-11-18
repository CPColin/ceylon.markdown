// Ported from commonmark.js/lib/render/html.js

import ceylon.markdown.parser {
    entity
}
import ceylon.regex {
    regex
}

"Escapes dangerous characters in the given [[string]] by substituting in their equivalent HTML
 entities. If [[preserveEntities]] is `true`, this function will avoid double-escaping HTML entities
 that it finds."
shared String escapeHtml(String string, Boolean preserveEntities = false) {
    value xmlSpecial = """[&<>"]""";
    
    value regexXmlSpecial => regex {
        expression = xmlSpecial;
        global = true;
    };
    
    value regexXmlSpecialOrEntity => regex {
        expression = entity + "|" + xmlSpecial;
        global = true;
        ignoreCase = true;
    };
    
    function replaceUnsafeCharacter(String string)
            => switch (string)
                case ("&") "&amp;"
                case ("<") "&lt;"
                case (">") "&gt;"
                case ("\"") "&quot;"
                else string;
    
    if (regexXmlSpecial.test(string)) {
        if (preserveEntities) {
            return regexXmlSpecialOrEntity.replace(string, replaceUnsafeCharacter);
        } else {
            return regexXmlSpecial.replace(string, replaceUnsafeCharacter);
        }
    } else {
        return string;
    }
}
