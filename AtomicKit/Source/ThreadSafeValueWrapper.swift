/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2017 Jean-David Gadina - www.xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Foundation

/**
 * Protocol for `AtomicKit` thread-safe wrapper objects around a value/type.
 */
public protocol ThreadSafeValueWrapper
{
    associatedtype ValueType
    
    /**
     * Required initializer.  
     * Initializes a thread-safe wrapper object with a default value.
     * 
     * - parameter value: The default value for the wrapped type.
     */
    init( value: ValueType )
    
    /**
     * Atomically gets the value of the wrapped type.
     * 
     * - returns:   The actual value of the wrapped type.
     */
    func get() -> ValueType
    
    /**
     * Atomically sets the value of the wrapped type.
     * 
     * - parameter value: The value to set for the wrapped type.
     */
    func set( _ value: ValueType )
    
    /**
     * Atomically executes a custom closure, receiving the value of the wrapped
     * type.
     *
     * The passed closure is guaranteed to be executed atomically, in respect
     * of the current value of the wrapped type.
     * 
     * - parameter  closure: The close to execute.
     */
    func execute( closure: ( ValueType ) -> Swift.Void )
    
    /**
     * Atomically executes a custom closure, receiving the value of the wrapped
     * type.
     *
     * The passed closure is guaranteed to be executed atomically, in respect
     * of the current value of the wrapped type.
     * 
     * - parameter  closure: The close to execute.
     * - returns:   The closure's return value.
     */
    func execute< R >( closure: ( ValueType ) -> R ) -> R
}
