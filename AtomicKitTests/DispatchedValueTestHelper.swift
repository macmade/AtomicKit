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

import XCTest
import AtomicKit

class DispatchedValueTestHelper< T: DispatchedValueWrapper, U > where U: Equatable
{
    let _queue = DispatchQueue( label: "com.xs-labs.AtomicKit.DispatchedValueTest" )
    let _key   = DispatchSpecificKey< String >()
    let _uuid  = UUID().uuidString
    
    var _v1:      T
    var _v2:      T
    var _test:    XCTestCase
    var _default: T.ValueType
    
    init( defaultValue: T.ValueType, testCase: XCTestCase )
    {
        self._v1      = T( value: defaultValue, queue: self._queue )
        self._v2      = T( value: defaultValue )
        self._test    = testCase
        self._default = defaultValue
        
        self._queue.setSpecific( key: self._key, value: self._uuid )
    }
    
    func testGetSet_MainQueue( value: T.ValueType, notValue: T.ValueType )
    {
        self.testGetSet( value: value, notValue: notValue, queue: DispatchQueue.main )
    }
    
    func testGetSet_GlobalQueue( value: T.ValueType, notValue: T.ValueType )
    {
        self.testGetSet( value: value, notValue: notValue, queue: DispatchQueue.global( qos: .userInitiated ) )
    }
    
    func testGetSet_CustomQueue( value: T.ValueType, notValue: T.ValueType )
    {
        self.testGetSet( value: value, notValue: notValue, queue: self._queue )
    }
    
    func testExecute_NoReturn_MainQueue( value: T.ValueType, notValue: T.ValueType )
    {
        self.testExecute_NoReturn( value: value, notValue: notValue, queue: DispatchQueue.main )
    }
    
    func testExecute_NoReturn_GlobalQueue( value: T.ValueType, notValue: T.ValueType )
    {
        self.testExecute_NoReturn( value: value, notValue: notValue, queue: DispatchQueue.global( qos: .userInitiated ) )
    }
    
    func testExecute_NoReturn_CustomQueue( value: T.ValueType, notValue: T.ValueType )
    {
        self.testExecute_NoReturn( value: value, notValue: notValue, queue: self._queue )
    }
    
    func testExecute_Return_MainQueue( value: T.ValueType, notValue: T.ValueType )
    {
        self.testExecute_Return( value: value, notValue: notValue, queue: DispatchQueue.main )
    }
    
    func testExecute_Return_GlobalQueue( value: T.ValueType, notValue: T.ValueType )
    {
        self.testExecute_Return( value: value, notValue: notValue, queue: DispatchQueue.global( qos: .userInitiated ) )
    }
    
    func testExecute_Return_CustomQueue( value: T.ValueType, notValue: T.ValueType )
    {
        self.testExecute_Return( value: value, notValue: notValue, queue: self._queue )
    }
    
    func testGetSet( value: T.ValueType, notValue: T.ValueType, queue: DispatchQueue )
    {
        let e = self._test.expectation( description: "testGetSet" )
        
        queue.async
        {
            self._v1.set( self._default );
            self._v2.set( self._default );
            
            XCTAssertEqual( self._v1.get() as? U, self._default as? U )
            XCTAssertEqual( self._v2.get() as? U, self._default as? U )
            
            self._v1.set( value );
            self._v2.set( value );
            
            XCTAssertEqual( self._v1.get() as? U, value as? U )
            XCTAssertEqual( self._v2.get() as? U, value as? U )
            XCTAssertNotEqual( self._v1.get() as? U, notValue as? U )
            XCTAssertNotEqual( self._v2.get() as? U, notValue as? U )
            
            e.fulfill()
        }
        
        self._test.waitForExpectations( timeout: 1 )
    }
    
    func testExecute_NoReturn( value: T.ValueType, notValue: T.ValueType, queue: DispatchQueue )
    {
        let e = self._test.expectation( description: "testExecute_NoReturn" )
        
        queue.async
        {
            self._v1.set( self._default );
            XCTAssertEqual( self._v1.get() as? U, self._default as? U )
            
            self._v1.execute
            {
                ( v: T.ValueType ) in
                
                XCTAssertEqual( v as? U, self._default as? U )
                XCTAssertEqual( DispatchQueue.getSpecific( key: self._key ), self._uuid )
            }
            
            self._v1.set( value );
            XCTAssertEqual( self._v1.get() as? U, value as? U )
            
            self._v1.execute
            {
                ( v: T.ValueType ) in
                
                XCTAssertEqual( v as? U, value as? U )
                XCTAssertNotEqual( v as? U, notValue as? U )
                XCTAssertEqual( DispatchQueue.getSpecific( key: self._key ), self._uuid )
            }
            
            self._v2.set( self._default );
            XCTAssertEqual( self._v2.get() as? U, self._default as? U )
            
            self._v2.execute
            {
                ( v: T.ValueType ) in
                
                XCTAssertEqual( v as? U, self._default as? U )
                XCTAssertEqual( DispatchQueue.getSpecific( key: self._key ), DispatchQueue.main.getSpecific( key: self._key ) )
            }
            
            self._v2.set( value );
            XCTAssertEqual( self._v1.get() as? U, value as? U )
            
            self._v2.execute
            {
                ( v: T.ValueType ) in
                
                XCTAssertEqual( v as? U, value as? U )
                XCTAssertNotEqual( v as? U, notValue as? U )
                XCTAssertEqual( DispatchQueue.getSpecific( key: self._key ), DispatchQueue.main.getSpecific( key: self._key ) )
            }
            
            e.fulfill()
        }
        
        self._test.waitForExpectations( timeout: 1 )
    }
    
    func testExecute_Return( value: T.ValueType, notValue: T.ValueType, queue: DispatchQueue )
    {
        let e = self._test.expectation( description: "testExecute_Return_MainQueue" )
        
        queue.async
        {
            self._v1.set( self._default );
            XCTAssertEqual( self._v1.get() as? U, self._default as? U )
            
            let r1 = self._v1.execute
            {
                ( v: T.ValueType ) -> Int in
                
                XCTAssertEqual( v as? U, self._default as? U )
                XCTAssertEqual( DispatchQueue.getSpecific( key: self._key ), self._uuid )
                
                return 42
            }
            
            XCTAssertEqual( r1, 42 )
            
            self._v1.set( value );
            XCTAssertEqual( self._v1.get() as? U, value as? U )
            
            let r2 = self._v1.execute
            {
                ( v: T.ValueType ) -> Int in
                
                XCTAssertEqual( v as? U, value as? U )
                XCTAssertNotEqual( v as? U, notValue as? U )
                XCTAssertEqual( DispatchQueue.getSpecific( key: self._key ), self._uuid )
                
                return 42
            }
            
            XCTAssertEqual( r2, 42 )
            
            self._v2.set( value );
            XCTAssertEqual( self._v2.get() as? U, value as? U )
            
            let r3 = self._v2.execute
            {
                ( v: T.ValueType ) -> Int in
                
                XCTAssertEqual( v as? U, value as? U )
                XCTAssertEqual( DispatchQueue.getSpecific( key: self._key ), DispatchQueue.main.getSpecific( key: self._key ) )
                
                return 42
            }
            
            XCTAssertEqual( r3, 42 )
            
            self._v2.set( value );
            XCTAssertEqual( self._v2.get() as? U, value as? U )
            
            let r4 = self._v2.execute
            {
                ( v: T.ValueType ) -> Int in
                
                XCTAssertEqual( v as? U, value as? U )
                XCTAssertNotEqual( v as? U, notValue as? U )
                XCTAssertEqual( DispatchQueue.getSpecific( key: self._key ), DispatchQueue.main.getSpecific( key: self._key ) )
                
                return 42
            }
            
            XCTAssertEqual( r4, 42 )
            
            e.fulfill()
        }
        
        self._test.waitForExpectations( timeout: 1 )
    }
}
