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

class LockingValueTest: XCTestCase
{
    var _helper1: LockingValueTestHelper< PossiblyUnfairLock, Int, LockingValue< Int, PossiblyUnfairLock > >?
    var _helper2: LockingValueTestHelper< Mutex,              Int, LockingValue< Int, Mutex > >?
    var _helper3: LockingValueTestHelper< RecursiveMutex,     Int, LockingValue< Int, RecursiveMutex > >?
    var _helper4: LockingValueTestHelper< NSLock,             Int, LockingValue< Int, NSLock > >?
    
    override func setUp()
    {
        super.setUp()
        
        do
        {
            try self._helper1 = LockingValueTestHelper( defaultValue: 0, testCase: self, lock: PossiblyUnfairLock() )
            try self._helper2 = LockingValueTestHelper( defaultValue: 0, testCase: self, lock: Mutex() )
            try self._helper3 = LockingValueTestHelper( defaultValue: 0, testCase: self, lock: RecursiveMutex() )
                self._helper4 = LockingValueTestHelper( defaultValue: 0, testCase: self, lock: NSLock() )
        }
        catch
        {
            XCTFail( "Failed to setup unit-test" )
        }
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    func testGetSet_MainQueue()
    {
        self._helper1!.testGetSet_MainQueue( value: 42, notValue: 43 )
        self._helper2!.testGetSet_MainQueue( value: 42, notValue: 43 )
        self._helper3!.testGetSet_MainQueue( value: 42, notValue: 43 )
        self._helper4!.testGetSet_MainQueue( value: 42, notValue: 43 )
    }
    
    func testGetSet_GlobalQueue()
    {
        self._helper1!.testGetSet_GlobalQueue( value: 42, notValue: 43 )
        self._helper2!.testGetSet_GlobalQueue( value: 42, notValue: 43 )
        self._helper3!.testGetSet_GlobalQueue( value: 42, notValue: 43 )
        self._helper4!.testGetSet_GlobalQueue( value: 42, notValue: 43 )
    }
    
    func testExecute_NoReturn_MainQueue()
    {
        self._helper1!.testExecute_NoReturn_MainQueue( value: 42, notValue: 43 )
        self._helper2!.testExecute_NoReturn_MainQueue( value: 42, notValue: 43 )
        self._helper3!.testExecute_NoReturn_MainQueue( value: 42, notValue: 43 )
        self._helper4!.testExecute_NoReturn_MainQueue( value: 42, notValue: 43 )
    }
    
    func testExecute_NoReturn_GlobalQueue()
    {
        self._helper1!.testExecute_NoReturn_GlobalQueue( value: 42, notValue: 43 )
        self._helper2!.testExecute_NoReturn_GlobalQueue( value: 42, notValue: 43 )
        self._helper3!.testExecute_NoReturn_GlobalQueue( value: 42, notValue: 43 )
        self._helper4!.testExecute_NoReturn_GlobalQueue( value: 42, notValue: 43 )
    }
    
    func testExecute_Return_MainQueue()
    {
        self._helper1!.testExecute_Return_MainQueue( value: 42, notValue: 43 )
        self._helper2!.testExecute_Return_MainQueue( value: 42, notValue: 43 )
        self._helper3!.testExecute_Return_MainQueue( value: 42, notValue: 43 )
        self._helper4!.testExecute_Return_MainQueue( value: 42, notValue: 43 )
    }
    
    func testExecute_Return_GlobalQueue()
    {
        self._helper1!.testExecute_Return_GlobalQueue( value: 42, notValue: 43 )
        self._helper2!.testExecute_Return_GlobalQueue( value: 42, notValue: 43 )
        self._helper3!.testExecute_Return_GlobalQueue( value: 42, notValue: 43 )
        self._helper4!.testExecute_Return_GlobalQueue( value: 42, notValue: 43 )
    }
}

