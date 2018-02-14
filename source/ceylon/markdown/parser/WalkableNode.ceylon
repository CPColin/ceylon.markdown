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

shared dynamic WalkableNode<Type> {
    shared formal String? destination;
    
    shared formal Type? firstChild;
    
    shared formal String? info;
    
    shared formal Boolean isContainer;
    
    shared formal Type? lastChild;
    
    shared formal Integer? level;
    
    shared formal String? listDelimiter;
    
    shared formal Integer? listStart;
    
    shared formal Boolean? listTight;
    
    shared formal String? listType;
    
    shared formal variable String? literal;
    
    shared formal Type? next;
    
    shared formal Type? parent;
    
    shared formal Type? prev;
    
    shared formal String? title;
    
    shared formal String type;
}
