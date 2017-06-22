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

/*!
 * @file        DispatchedValue.swift
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

import Foundation

public class DispatchedValue< T >: ThreadSafeValueWrapper
{
    public typealias ValueType = T
    
    public required convenience init( value: T )
    {
        self.init( value: value, queue: DispatchQueue.main )
    }
    
    public init( value: T, queue: DispatchQueue )
    {
        self._queue = queue
        self._value = value
        
        self._queue.setSpecific( key: self._key, value: self._uuid )
    }
    
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

