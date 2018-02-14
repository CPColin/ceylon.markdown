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
    Writer,
    createFileIfNil,
    current
}
import ceylon.http.client {
    get
}
import ceylon.uri {
    parse
}

import test.ceylon.markdown {
    fetchedCommonmarkJsVersion
}

"Fetches the CommonMark spec from the `commonmark.js` repository and converts its examples into
 Ceylon classes. Note that the CommonMark spec publishes a `spec.json` file that could be easier to
 deal with, but we target the `commonmark.js` tests because this implementation was based off of
 that code."
shared void run() {
    variable value count = 0;
    
    class Parser(Writer writer, Iterator<String> iterator, String baseClass,
        String? otherFile, Boolean smartPunctuation) {
        late variable String section;
        
        late variable String version;
        
        function skipToExampleStart() {
            value sectionStart = "# ";
            value subsectionStart = "## ";
            value versionStart = "version: ";
            
            variable String|Finished line = "";
            
            while (true) {
                line = iterator.next();
                
                if (line is Finished) {
                    return false;
                }
                
                assert (is String lineString = line);
                
                if (lineString == """```````````````````````````````` example""") {
                    return true;
                } else if (lineString.startsWith(sectionStart)) {
                    section = lineString.substring(sectionStart.size);
                } else if (lineString.startsWith(subsectionStart)) {
                    section = lineString.substring(subsectionStart.size);
                } else if (lineString.startsWith(versionStart)) {
                    version = lineString.substring(versionStart.size);
                }
            }
        }
        
        void writeLines(String until) {
            variable String|Finished line = "";
            
            writer.write("        \"\"\"");
            
            while (true) {
                line = iterator.next();
                
                if (line is Finished) {
                    return;
                } else if (line == until) {
                    break;
                }
                
                writer.writeLine(line.string.replace("→", "\t"));
                writer.write("           ");
            }
            
            writer.write("\"\"\"");
        }
        
        while (skipToExampleStart()) {
            writer.writeLine(count > 0 then "," else "");
            
            count++;
            
            value sectionName = "``section.replace(" ", "_")``";
            
            writer.writeLine("    [");
            
            if (exists otherFile) {
                writer.writeLine("        \"``otherFile`` ``count``\",");
            } else {
                writer.writeLine("        \"``sectionName`` ``count`` \
                                  (http://spec.commonmark.org/``version``/#example-``count``)\",");
            }
            
            writeLines(".");
            writer.writeLine(",");
            writeLines("""````````````````````````````````""");
            if (smartPunctuation) {
                writer.writeLine(",");
                writer.writeLine("        true");
            }
            else {
                writer.writeLine();
            }
            writer.write("    ]");
        }
    }
    
    value filePath = current.childPath("source/test/ceylon/markdown/specTests.ceylon");
    value file = filePath.resource;
    
    assert (is File|Nil file);
    
    try (writer = createFileIfNil(file).Overwriter("UTF-8")) {
        void parseTests(String baseClass = "SpecTest", String? otherFile = null,
            Boolean smartPunctuation = false) {
            value fileName = otherFile else "spec.txt";
            value specUri = parse("https://raw.githubusercontent.com/jgm/commonmark.js/\
                                   ``fetchedCommonmarkJsVersion``/test/``fileName``");
            value response = get(specUri).execute();
            
            Parser(writer, response.contents.lines.iterator(), baseClass, otherFile,
                smartPunctuation);
        }
        
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
        writer.writeLine("// This file was generated by util.ceylon.markdown.fetchspectests::run().
                          // Hand-edits will be lost the next time that function runs.");
        
        writer.write("{[ String, String, String ]|[ String, String, String, Boolean ]*} specTests = {");
        
        parseTests();
        parseTests("SmartPunctuationTest", "smart_punct.txt", true);
        parseTests("SpecTest", "regression.txt");
        
        writer.writeLine();
        writer.writeLine("};");
    }
    
    print("Wrote ``count`` tests.");
}
