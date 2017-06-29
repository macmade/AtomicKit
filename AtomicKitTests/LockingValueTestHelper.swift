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

class LockingValueTestHelper< L, U, T: LockingValue< U, L > > where U: Equatable
{
    var _values:  [ T ]
    var _test:    XCTestCase
    var _default: T.ValueType
    
    init( defaultValue: T.ValueType, testCase: XCTestCase, lock: NSLocking )
    {
        self._values  = [ T( value: defaultValue, lock: lock ), T( value: defaultValue ) ]
        self._test    = testCase
        self._default = defaultValue
    }
    
    func testGetSet_MainQueue( value: T.ValueType, notValue: T.ValueType )
    {
        self.testGetSet( value: value, notValue: notValue, queue: DispatchQueue.main )
    }
    
    func testGetSet_GlobalQueue( value: T.ValueType, notValue: T.ValueType )
    {
        self.testGetSet( value: value, notValue: notValue, queue: DispatchQueue.global( qos: .userInitiated ) )
    }
    
    func testExecute_NoReturn_MainQueue( value: T.ValueType, notValue: T.ValueType )
    {
        self.testExecute_NoReturn( value: value, notValue: notValue, queue: DispatchQueue.main )
    }
    
    func testExecute_NoReturn_GlobalQueue( value: T.ValueType, notValue: T.ValueType )
    {
        self.testExecute_NoReturn( value: value, notValue: notValue, queue: DispatchQueue.global( qos: .userInitiated ) )
    }
    
    func testExecute_Return_MainQueue( value: T.ValueType, notValue: T.ValueType )
    {
        self.testExecute_Return( value: value, notValue: notValue, queue: DispatchQueue.main )
    }
    
    func testExecute_Return_GlobalQueue( value: T.ValueType, notValue: T.ValueType )
    {
        self.testExecute_Return( value: value, notValue: notValue, queue: DispatchQueue.global( qos: .userInitiated ) )
    }
    
    func testGetSet( value: T.ValueType, notValue: T.ValueType, queue: DispatchQueue )
    {
        let e = self._test.expectation( description: "testGetSet" )
        
        queue.async
        {
            for v in self._values
            {
                v.set( self._default );
                
                XCTAssertEqual( v.get(), self._default )
                
                v.set( value );
                
                XCTAssertEqual( v.get(), value )
                XCTAssertNotEqual( v.get(), notValue )
            }
            
            e.fulfill()
        }
        
        self._test.waitForExpectations( timeout: 1 )
    }
    
    func testExecute_NoReturn( value: T.ValueType, notValue: T.ValueType, queue: DispatchQueue )
    {
        let e = self._test.expectation( description: "testExecute_NoReturn" )
        
        queue.async
        {
            for v in self._values
            {
                v.set( self._default );
                XCTAssertEqual( v.get(), self._default )
                
                v.execute
                {
                    ( v: T.ValueType ) in
                    
                    XCTAssertEqual( v, self._default )
                }
                
                v.set( value );
                XCTAssertEqual( v.get(), value )
                
                v.execute
                {
                    ( v: T.ValueType ) in
                    
                    XCTAssertEqual( v, value )
                    XCTAssertNotEqual( v, notValue )
                }
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
            for v in self._values
            {
                v.set( self._default );
                XCTAssertEqual( v.get(), self._default )
                
                let r1 = v.execute
                {
                    ( v: T.ValueType ) -> Int in
                    
                    XCTAssertEqual( v, self._default )
                    
                    return 42
                }
                
                XCTAssertEqual( r1, 42 )
                
                v.set( value );
                XCTAssertEqual( v.get(), value )
                
                let r2 = v.execute
                {
                    ( v: T.ValueType ) -> Int in
                    
                    XCTAssertEqual( v, value )
                    XCTAssertNotEqual( v, notValue )
                    
                    return 42
                }
                
                XCTAssertEqual( r2, 42 )
            }
            
            e.fulfill()
        }
        
        self._test.waitForExpectations( timeout: 1 )
    }
}
