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
