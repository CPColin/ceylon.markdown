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
