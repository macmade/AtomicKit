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
 * Represents a thread-safe value wrapper, using locking to achieve
 * synchronization.  
 * Note that this class is not KVO-compliant.  
 * If you need this, please use subclasses of `DispatchedValue`.
 * 
 * - seealso: `DispatchedValue`
 * - seealso: `ThreadSafeValueWrapper`
 */
public class LockingValue< T, L >: ThreadSafeValueWrapper where L: NSLocking
{
    /**
     * The wrapped value type.
     */
    public typealias ValueType = T
    
    /**
     * Initializes a locking value object.
     * 
     * - parameter value:   The initial value.
     * - parameter lock:    The lock to use to achieve synchronization. Must conform to `NSLocking`.
     */
    public required init( value: ValueType, lock: NSLocking )
    {
        self._value = value
        self._lock  = lock
    }
    
    /**
     * Initializes a locking value object.
     * 
     * - parameter value:   The initial value.
     */
    public required convenience init( value: ValueType )
    {
        do
        {
            if let t = L.self as? Lockable.Type
            {
                try self.init( value: value, lock: t.init() )
                
                return
            }
        }
        catch
        {}
        
        #if DEBUG
        print( "Initialization of " + String( describing: L.self ) + " failed! Falling back to NSRecursiveLock." )
        #endif
        
        self.init( value: value, lock: NSRecursiveLock() )
    }
    
    /**
     * Atomically gets the wrapped value.
     * 
     * - returns:   The actual value.
     */
    public func get() -> ValueType
    {
        self._lock.lock()
        
        let value = self._value
    
        self._lock.unlock()
        
        return value
    }
    
    /**
     * Atomically sets the wrapped value.
     * 
     * -parameter value: The value to set.
     */
    public func set( _ value: ValueType )
    {
        self._lock.lock()
        
        self._value = value
    
        self._lock.unlock()
    }
    
    /**
     * Atomically executes a closure on the wrapped value.  
     * The closure will be passed the actual value of the wrapped value,
     * and is guaranteed to be executed atomically.
     * 
     * -parameter closure: The close to execute.
     */
    public func execute( closure: ( ValueType ) -> Swift.Void )
    {
        self._lock.lock()
        
        closure( self._value );
    
        self._lock.unlock()
    }
    
    /**
     * Atomically executes a closure on the wrapped value, returning some value.  
     * The closure will be passed the actual value of the wrapped value,
     * and is guaranteed to be executed atomically.
     * 
     * -parameter closure: The close to execute, returning some value.
     */
    public func execute< R >( closure: ( ValueType ) -> R ) -> R
    {
        self._lock.lock()
        
        let ret = closure( self._value );
    
        self._lock.unlock()
        
        return ret
    }
    
    private var _value: ValueType
    private var _lock:  NSLocking
}
