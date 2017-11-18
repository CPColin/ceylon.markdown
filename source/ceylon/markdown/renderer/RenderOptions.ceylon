// Ported from commonmark.js/lib/render/html.js

shared class RenderOptions(
    //"An optional language to use for code blocks, when no other language is specified."
    //shared String? defaultLanguage = null,
    //"When enabled, turns all heading elements into links that anchor to themselves, making it easier
    // for authors to link to specific sections of a page."
    //shared Boolean linkHeadings = false,
    shared Boolean safe = false,
    "By default, soft breaks are rendered as newlines in HTML.
     Set to \"<br />\" to make them hard breaks.
     Set to \" \" if you want to ignore line wrapping in source."
    shared String softBreak = "\n",
    shared Boolean sourcePos = false
) {}
