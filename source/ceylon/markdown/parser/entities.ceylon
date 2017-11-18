import ceylon.regex {
    Regex,
    regex
}

shared object entities {
    value regexDecimalEntity => regex {
        expression = "&#([0-9]{1,8});";
    };
    
    value regexHexadecimalEntity => regex {
        expression = "&#x([a-f0-9]{1,8});";
        ignoreCase = true;
    };
    
    shared Map<String, String> encodeMap = map({
        for (key->item in entityMap)
            item->key
    });
    
    function decodeNumericEntity(Regex regex, String input, Integer radix) {
        if (exists match = regex.find(input),
                exists group = match.groups[0],
                is Integer codepoint = Integer.parse(group, radix)) {
            if (0 < codepoint <= #01ffff) {
                return codepoint.character.string;
            } else {
                return "\{REPLACEMENT CHARACTER}";
            }
        } else {
            return null;
        }
    }
    
    shared String decode(String input) {
        String? decoded;
        
        if (exists string = decodeNumericEntity(regexDecimalEntity, input, 10)) {
            decoded = string;
        } else if (exists string = decodeNumericEntity(regexHexadecimalEntity, input, 16)) {
            decoded = string;
        } else {
            decoded = entityMap[input];
        }
        
        return decoded else input;
    }
    
    shared String encode(String character) => encodeMap[character] else character;
}
