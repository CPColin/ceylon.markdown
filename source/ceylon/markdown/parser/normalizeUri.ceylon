import ceylon.buffer.charset {
    utf8
}
import ceylon.uri {
    InvalidUriException,
    parse
}

String normalizeUri(String uri) {
    // Unfortunately, ceylon.uri::parse expects an ASCII string, so we need to percent-encode the
    // UTF-8 bytes first, parse that to a URI, and get the percent-encoded version of *that*.
    value asciiUri = String(expand({
        for (byte in utf8.encode(uri))
            byte.unsigned > 127
            then
                "%" + Integer.format(byte.unsigned, 16).uppercased
            else
                {byte.unsigned.character}
    }));
    
    try {
        return parse(asciiUri).string;
    } catch (InvalidUriException e) {
        return uri;
    }
}
