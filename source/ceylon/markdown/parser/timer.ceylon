import ceylon.collection {
    HashMap,
    MutableMap
}

object timer {
    MutableMap<String, Integer> timers = HashMap<String, Integer>();
    
    shared void start(String key) {
        timers[key] = system.milliseconds;
    }
    
    shared void end(String key) {
        if (exists start = timers[key]) {
            print("``key``: ``system.milliseconds - start`` ms");
            timers.remove(key);
        }
    }
}
