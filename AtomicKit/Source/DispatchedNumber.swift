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
 * Thread-safe value wrapper for `NSNumber`, using dispatch queues to
 * achieve synchronization.
 * This class is KVO-compliant. You may observe its `value` property to be
 * notified of changes. This is applicable to Cocoa bindings.
 * 
 * - seealso: DispatchedValueWrapper
 */
@objc public class DispatchedNumber: NSObject, DispatchedValueWrapper
{
    /**
     * The wrapped value type, `NSNumber`.
     */
    public typealias ValueType = NSNumber?
    
    /**
     * Initializes a dispatched value object.  
     * This initializer will use the main queue for synchronization.
     * 
     * - parameter value:   The initial      value.
     */
    public required convenience init( value: ValueType )
    {
        self.init( value: value, queue: DispatchQueue.main )
    }
    
    /**
     * Initializes a dispatched value object.  
     * 
     * - parameter value:   The initial `NSNumber` value.
     * - parameter queue:   The queue to use to achieve synchronization.
     */
    public required init( value: ValueType = nil, queue: DispatchQueue = DispatchQueue.main )
    {
        self._value = DispatchedValue< ValueType >( value: value, queue: queue )
    }
    
    /**
     * The wrapped `NSNumber` value.  
     * This property is KVO-compliant.
     */
    @objc public dynamic var value: ValueType
    {
        get
        {
            return self._value.get()
        }
        
        set( value )
        {
            self.willChangeValue( forKey: "value" )
            self._value.set( value )
            self.didChangeValue( forKey: "value" )
        }
    }
    
    /**
     * Atomically gets the wrapped `NSNumber` value.  
     * The getter will be executed on the queue specified in the initialzer.
     * 
     * - returns:   The actual `NSNumber` value.
     */
    public func get() -> ValueType
    {
        return self.value
    }
    
    /**
     * Atomically sets the wrapped `NSNumber` value.  
     * The setter will be executed on the queue specified in the initialzer.
     * 
     * -parameter value: The `NSNumber` value to set.
     */
    public func set( _ value: ValueType )
    {
        self.value = value
    }
    
    /**
     * Atomically executes a closure on the wrapped `NSNumber` value.  
     * The closure will be passed the actual value of the wrapped
     * `NSNumber` value, and is guaranteed to be executed atomically,
     * on the queue specified in the initialzer.
     * 
     * -parameter closure: The close to execute.
     */
    public func execute( closure: ( ValueType ) -> Swift.Void )
    {
        self._value.execute( closure: closure )
    }
    
    /**
     * Atomically executes a closure on the wrapped `NSNumber` value,
     * returning some value.
     * The closure will be passed the actual value of the wrapped
     * `NSNumber` value, and is guaranteed to be executed atomically,
     * on the queue specified in the initialzer.
     * 
     * -parameter closure: The close to execute, returning some value.
     */
    public func execute< R >( closure: ( ValueType ) -> R ) -> R
    {
        return self._value.execute( closure: closure )
    }
    
    private var _value: DispatchedValue< ValueType >
}


