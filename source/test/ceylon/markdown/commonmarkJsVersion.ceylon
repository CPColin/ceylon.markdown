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

import ceylon.test {
    assertEquals,
    test
}

"The version of `commonmark.js` that was used when fetching the spec and generating
 [[specTests]]. The below test compares this value against [[importedCommonmarkJsVersion]] when
 running on the JS backend."
shared String fetchedCommonmarkJsVersion = "0.28.1";

"The version of `commonmark.js` that was imported by the descriptor of this module when running on
 the JS backend."
native shared String importedCommonmarkJsVersion = "N/A";

native("js") shared String importedCommonmarkJsVersion {
    value commonmarkModule = `module`.dependencies.find((mod) => mod.name == "commonmark");
    
    assert (exists commonmarkModule);
    
    return commonmarkModule.version;
}

native shared void verifyCommonmarkJsVersion() {}

test
native("js") shared void verifyCommonmarkJsVersion() {
    assertEquals(importedCommonmarkJsVersion, fetchedCommonmarkJsVersion,
        "The imported version of commonmark.js differs from the one used to create the tests.
         Please run utility.ceylon.markdown.fetchspectests::run()");
}
