/*****************************************************************************
 * Copyright © 2018 Colin Bartolome
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy
 * of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 *****************************************************************************/

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
String escapeHtml(String string, Boolean preserveEntities = false) {
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
