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

import ceylon.file {
    File,
    Nil,
    current,
    createFileIfNil
}
import ceylon.http.client {
    get
}
import ceylon.json {
    JsonObject=Object,
    JsonValue=Value,
    parseJson=parse
}
import ceylon.uri {
    parseUri=parse
}

"Fetches the list of HTML entities and converts it into a format that Ceylon code can use."
shared void run() {
    value uri = parseUri("https://html.spec.whatwg.org/entities.json");
    
    function fetchJson() {
        value response = get(uri).execute().contents;
        value json = parseJson(response);
        
        assert (is JsonObject json);
        
        return json;
    }
    
    function formatCodepoint(Integer codepoint) {
        value formatted = Integer.format(codepoint, 16);
        
        if (formatted.size % 2 == 0) {
            return formatted;
        } else {
            return "0" + formatted;
        }
    }
    
    function parseCodepoints(JsonValue jsonValue) {
        assert (is JsonObject jsonValue);
        
        value codepoints = jsonValue.getArray("codepoints");
        
        return String(expand {
            for (codepoint in codepoints.narrow<Integer>())
                "\\{#``formatCodepoint(codepoint)``}"
        });
    }
    
    function parseEntities(JsonObject json) => {
        for (key -> item in json)
            if (key.endsWith(";"))
                key -> parseCodepoints(item)
    };
    
    void createEntityMap({<String->String>*} entities) {
        value file = current
            .childPath("source/ceylon/markdown/parser/entityMap.ceylon")
            .resource;
        
        assert (is File|Nil file);
        
        try (writer = createFileIfNil(file).Overwriter("UTF-8")) {
            writer.writeLine("/*****************************************************************************
                               * Copyright © 2018 Colin Bartolome
                               * 
                               * Licensed under the Apache License, Version 2.0 (the \"License\"); you may not
                               * use this file except in compliance with the License. You may obtain a copy
                               * of the License at
                               * 
                               *    http://www.apache.org/licenses/LICENSE-2.0
                               * 
                               * Unless required by applicable law or agreed to in writing, software
                               * distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT
                               * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
                               * License for the specific language governing permissions and limitations
                               * under the License.
                               *****************************************************************************/
                              ");
            writer.writeLine("\"Maps HTML entites to the character(s) they represent.");
            writer.writeLine(" This file was created by `util.ceylon.markdown.fetchentitymap::run`");
            writer.writeLine(" and was parsed from [the HTML spec](``uri``).\"");
            writer.writeLine("shared Map<String, String> entityMap = map({");
            {
                for (entity -> string in entities)
                    "    \"``entity``\" -> \"``string``\""
            }.interpose(",\n").each(writer.write);
            writer.writeLine("\n});");
        }
    }
    
    value json = fetchJson();
    value entities = parseEntities(json);
    
    createEntityMap(entities);
}
