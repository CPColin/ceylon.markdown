// Ported from commonmark.js/lib/blocks.js

shared class ListData(
    shared Character? bulletCharacter = null,
    shared String? delimiter = null,
    shared Integer? markerOffset = null,
    shared variable Integer? padding = null,
    shared Integer? start = null,
    shared variable Boolean? tight = null,
    shared String? type = null) {
    
    shared Boolean sameType(ListData? other)
        => if (exists other)
            then bothNullOrEqual(type, other.type)
                && bothNullOrEqual(delimiter, other.delimiter)
                && bothNullOrEqual(bulletCharacter, other.bulletCharacter)
            else false;
}
