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

"Options that can be passed to the [[Parser]] constructor, to control some of the parsing behavior."
shared class ParseOptions(
    """When enabled, turns quotation marks into "smart" or "curly" quotes, turns runs of hyphens
       into en- and em-dashes, and turns runs of periods into ellipses."""
    shared Boolean smart = false,
    """When enabled, parses "special" links, which are delimited by double square brackets."""
    shared Boolean specialLinks = false,
    "When enabled, logs timing statistics during parsing, for debugging."
    shared Boolean time = false
) {}
