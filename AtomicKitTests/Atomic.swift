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

class AtomicTest: XCTestCase
{
    var _helper1: LockingValueTestHelper< UnfairLock, Bool,     Atomic< Bool > >?
    var _helper2: LockingValueTestHelper< UnfairLock, Int,      Atomic< Int > >?
    var _helper3: LockingValueTestHelper< UnfairLock, String,   Atomic< String > >?
    var _helper4: LockingValueTestHelper< UnfairLock, NSNumber, Atomic< NSNumber > >?
    
    override func setUp()
    {
        super.setUp()
        
        self._helper1 = LockingValueTestHelper( defaultValue: false, testCase: self )
        self._helper2 = LockingValueTestHelper( defaultValue: 0,     testCase: self )
        self._helper3 = LockingValueTestHelper( defaultValue: "",    testCase: self )
        self._helper4 = LockingValueTestHelper( defaultValue: 0,     testCase: self )
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    func testGetSet_MainQueue()
    {
        self._helper1!.testGetSet_MainQueue( value: true,           notValue: false )
        self._helper2!.testGetSet_MainQueue( value: 42,             notValue: 43 )
        self._helper3!.testGetSet_MainQueue( value: "hello, world", notValue: "hello, universe" )
        self._helper4!.testGetSet_MainQueue( value: 42,             notValue: 43 )
    }
    
    func testGetSet_GlobalQueue()
    {
        self._helper1!.testGetSet_GlobalQueue( value: true,           notValue: false )
        self._helper2!.testGetSet_GlobalQueue( value: 42,             notValue: 43 )
        self._helper3!.testGetSet_GlobalQueue( value: "hello, world", notValue: "hello, universe" )
        self._helper4!.testGetSet_GlobalQueue( value: 42,             notValue: 43 )
    }
    
    func testExecute_NoReturn_MainQueue()
    {
        self._helper1!.testExecute_NoReturn_MainQueue( value: true,           notValue: false )
        self._helper2!.testExecute_NoReturn_MainQueue( value: 42,             notValue: 43 )
        self._helper3!.testExecute_NoReturn_MainQueue( value: "hello, world", notValue: "hello, universe" )
        self._helper4!.testExecute_NoReturn_MainQueue( value: 42,             notValue: 43 )
    }
    
    func testExecute_NoReturn_GlobalQueue()
    {
        self._helper1!.testExecute_NoReturn_GlobalQueue( value: true,           notValue: false )
        self._helper2!.testExecute_NoReturn_GlobalQueue( value: 42,             notValue: 43 )
        self._helper3!.testExecute_NoReturn_GlobalQueue( value: "hello, world", notValue: "hello, universe" )
        self._helper4!.testExecute_NoReturn_GlobalQueue( value: 42,             notValue: 43 )
    }
    
    func testExecute_Return_MainQueue()
    {
        self._helper1!.testExecute_Return_MainQueue( value: true,           notValue: false )
        self._helper2!.testExecute_Return_MainQueue( value: 42,             notValue: 43 )
        self._helper3!.testExecute_Return_MainQueue( value: "hello, world", notValue: "hello, universe" )
        self._helper4!.testExecute_Return_MainQueue( value: 42,             notValue: 43 )
    }
    
    func testExecute_Return_GlobalQueue()
    {
        self._helper1!.testExecute_Return_GlobalQueue( value: true,           notValue: false )
        self._helper2!.testExecute_Return_GlobalQueue( value: 42,             notValue: 43 )
        self._helper3!.testExecute_Return_GlobalQueue( value: "hello, world", notValue: "hello, universe" )
        self._helper4!.testExecute_Return_GlobalQueue( value: 42,             notValue: 43 )
    }
}


