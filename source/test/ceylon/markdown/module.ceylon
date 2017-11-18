module test.ceylon.markdown "1.0.0" {
    native("jvm") import ceylon.file "1.3.3";
    native("jvm") import ceylon.http.client "1.3.3";
    shared import ceylon.markdown "1.0.0";
    import ceylon.test "1.3.3";
    import ceylon.uri "1.3.3";
    native("js") import npm:"commonmark" "0.28.1";
}
