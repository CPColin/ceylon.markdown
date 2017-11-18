class Delimiter(
    shared Boolean canClose,
    shared Boolean canOpen,
    shared Character character,
    shared Node node,
    shared variable Integer numDelims,
    shared variable Delimiter? previous,
    shared variable Delimiter? next = null,
    shared Integer originalDelims = numDelims) {}
