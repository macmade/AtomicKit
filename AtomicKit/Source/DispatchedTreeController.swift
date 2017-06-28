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

import Cocoa

@objc public class DispatchedTreeController: NSObject, DispatchedValueWrapper
{
    public typealias ValueType = NSTreeController?
    
    public required convenience init( value: ValueType )
    {
        self.init( value: value, queue: DispatchQueue.main )
    }
    
    public required init( value: ValueType = nil, queue: DispatchQueue = DispatchQueue.main )
    {
        self._value = DispatchedValue< ValueType >( value: value, queue: queue )
    }
    
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
    
    public func get() -> ValueType
    {
        return self.value
    }
    
    public func set( _ value: ValueType )
    {
        self.value = value
    }
    
    public func execute( closure: ( ValueType ) -> Swift.Void )
    {
        self._value.execute( closure: closure )
    }
    
    public func execute< R >( closure: ( ValueType ) -> R ) -> R
    {
        return self._value.execute( closure: closure )
    }
    
    private var _value: DispatchedValue< ValueType >
}





