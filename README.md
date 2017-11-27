# ceylon.markdown
This is a port of the commonmark/commonmark.js Markdown parser and renderer from JavaScript to
Ceylon. Some parts have been made more ceylonic, for convenience, but the overall structure of the
code should resemble the original JavaScript, to make incorporating upstream changes easier.

This repository includes the main `ceylon.markdown` module, its accompanying suite of tests, and two
utility modules that generate parts of the code.

## Utility modules

### `util.ceylon.markdown.fetchentitymap`

This module creates `ceylon/markdown/parser/entityMap.ceylon`, which contains the same entity map
the original JavaScript code uses. This helps the Ceylon module produce identical output.

### `util.ceylon.markdown.fetchspectests`

The JavaScript code targets the commonmark/CommonMark spec for compliance testing, along with a few
other test cases. The `fetchspectests` module parses the spec and extracts the test cases from it,
allowing the Ceylon code to target the same tests.
