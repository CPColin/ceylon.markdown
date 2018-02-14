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

shared class RenderOptions(
    "An optional language to use for code blocks, when no other language is specified."
    shared String? defaultLanguage = null,
    "When enabled, turns all heading elements into links that anchor to themselves, making it easier
     for authors to link to specific sections of a page."
    shared Boolean linkHeadings = false,
    shared Boolean safe = false,
    "By default, soft breaks are rendered as newlines in HTML.
     Set to \"<br />\" to make them hard breaks.
     Set to \" \" if you want to ignore line wrapping in source."
    shared String softBreak = "\n",
    shared Boolean sourcePos = false
) {}
