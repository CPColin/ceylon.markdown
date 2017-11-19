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
