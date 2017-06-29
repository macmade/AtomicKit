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
 * Thread-safe value wrapper, using dispatch queues to achieve synchronization.  
 * Note that this class is not KVO-compliant.  
 * If you need this, please use subclasses of `DispatchedValue`.
 * 
 * - seealso: DispatchedValueWrapper
 */
public class DispatchedValue< T >: DispatchedValueWrapper
{
    /**
     * The wrapped value type.
     */
    public typealias ValueType = T
    
    /**
     * Initializes a dispatched value object.  
     * This initializer will use the main queue for synchronization.
     * 
     * - parameter value:   The initial value.
     */
    public required convenience init( value: T )
    {
        self.init( value: value, queue: DispatchQueue.main )
    }
    
    /**
     * Initializes a dispatched value object.  
     * 
     * - parameter value:   The initial value.
     * - parameter queue:   The queue to use to achieve synchronization.
     */
    public required init( value: T, queue: DispatchQueue )
    {
        self._queue = queue
        self._value = value
        
        self._queue.setSpecific( key: self._key, value: self._uuid )
    }
    
    /**
     * Atomically gets the wrapped value.  
     * The getter will be executed on the queue specified in the initialzer.
     * 
     * - returns:   The actual value.
     */
    public func get() -> T
    {
        if( DispatchQueue.getSpecific( key: self._key ) == self._uuid )
        {
            return self._value
        }
        else
        {
            return self._queue.sync( execute: { return self._value } );
        }
    }
    
    /**
     * Atomically sets the wrapped value.  
     * The setter will be executed on the queue specified in the initialzer.
     * 
     * -parameter value: The value to set.
     */
    public func set( _ value: T )
    {
        if( DispatchQueue.getSpecific( key: self._key ) == self._uuid )
        {
            self._value = value
        }
        else
        {
            self._queue.sync{ self._value = value }
        }
    }
    
    /**
     * Atomically executes a closure on the wrapped value.  
     * The closure will be passed the actual value of the wrapped value,
     * and is guaranteed to be executed atomically, on the queue specified in
     * the initialzer.
     * 
     * -parameter closure: The close to execute.
     */
    public func execute( closure: ( T ) -> Swift.Void )
    {
        if( DispatchQueue.getSpecific( key: self._key ) == self._uuid )
        {
            closure( self._value )
        }
        else
        {
            self._queue.sync{ closure( self._value ) }
        }
    }
    
    /**
     * Atomically executes a closure on the wrapped value, returning some value.  
     * The closure will be passed the actual value of the wrapped value,
     * and is guaranteed to be executed atomically, on the queue specified in
     * the initialzer.
     * 
     * -parameter closure: The close to execute, returning some value.
     */
    public func execute< R >( closure: ( T ) -> R ) -> R
    {
        if( DispatchQueue.getSpecific( key: self._key ) == self._uuid )
        {
            return closure( self._value )
        }
        else
        {
            return self._queue.sync( execute: { return closure( self._value ) } )
        }
    }
    
    private let _key  = DispatchSpecificKey< String >()
    private let _uuid = UUID().uuidString
    
    private var _queue: DispatchQueue
    private var _value: T
}

