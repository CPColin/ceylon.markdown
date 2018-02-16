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

"An attempt to make a straight (non-ceylonic) port of commonmarkdown.js to Ceylon."
suppressWarnings("ceylonNamespace")
module ceylon.markdown "1.0.0" {
    import ceylon.buffer "1.3.3";
    import ceylon.collection "1.3.3";
    shared import ceylon.html "1.3.3";
    import ceylon.regex "1.3.3";
    import ceylon.uri "1.3.3";
}
