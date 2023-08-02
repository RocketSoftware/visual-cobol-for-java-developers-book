      *****************************************************************
      *                                                               *
      * Copyright 2020-2023 Open Text. All Rights Reserved.           *
      * This software may be used, modified, and distributed          *
      * (provided this notice is included without modification)       *
      * solely for demonstration purposes with other                  *
      * Micro Focus software, and is otherwise subject to the EULA at *
      * https://www.microfocus.com/en-us/legal/software-licensing.    *
      *                                                               *
      * THIS SOFTWARE IS PROVIDED "AS IS" AND ALL IMPLIED           *
      * WARRANTIES, INCLUDING THE IMPLIED WARRANTIES OF               *
      * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE,         *
      * SHALL NOT APPLY.                                              *
      * TO THE EXTENT PERMITTED BY LAW, IN NO EVENT WILL              *
      * MICRO FOCUS HAVE ANY LIABILITY WHATSOEVER IN CONNECTION       *
      * WITH THIS SOFTWARE.                                           *
      *                                                               *
      *****************************************************************
      
       copy "mfunit_prototypes.cpy".
       
       identification division.
       program-id. MainProgramTest.

       data division.
       working-storage section.
       78 TEST-MultiplyTest value "MultiplyTest".
       78 TEST-DivideTest value "DivideTest".
       78 TEST-InvalidOpTest value "InvalidOpTest".

       copy "mfunit.cpy".
       01 operand1                 pic s9(15)v9(10).
       01 operand2                 pic s9(15)v9(10).
       01 operator-code            pic x. 
       01 result                   pic s9(15)v9(10).   
       01 displayable              pic x(28). 
       01 msg                      pic x(100). 
       78 program-under-test       value "Calculate".
       procedure division.

       entry MFU-TC-PREFIX & TEST-MultiplyTest.
           move 33 to operand1
           move 3.1 to operand2 
           move "M" to operator-code
           call program-under-test using by reference operand1 operand2
                                                 operator-code result
                                       returning return-code
           if result <> 102.3
               display result  
               call MFU-ASSERT-FAIL-Z using z"Expected 102.3"
           end-if
           goback returning return-code
           .

       entry MFU-TC-PREFIX & TEST-DivideTest.
           move 33 to operand1
           move 3.3 to operand2 
           move "D" to operator-code
           call program-under-test using by reference operand1 operand2
                                                 operator-code result
                                       returning return-code
           if result <> 10
               display result
               call MFU-ASSERT-FAIL-Z using z"Expected 10"
           end-if
           goback returning return-code
           .

       entry MFU-TC-PREFIX & TEST-InvalidOpTest.
           move 33 to operand1
           move 3.1 to operand2 
           move "X" to operator-code
           call program-under-test using by reference operand1 operand2
                                                 operator-code result
                                       returning return-code
           if return-code = 0
               call MFU-ASSERT-FAIL-Z using 
                                     z"Expected non-zero return code"
           else
      *        Zero return code before completing or test will be marked 
      *        as failed. 
               move 0 to return-code 
           end-if
           goback returning return-code
           .

      $region Test Configuration
       entry MFU-TC-SETUP-PREFIX & TEST-MultiplyTest.
       entry MFU-TC-SETUP-PREFIX & TEST-DivideTest.
       entry MFU-TC-SETUP-PREFIX & TEST-InvalidOpTest.
      $if JVMGEN set
           call "MainProgram"
      $else
           call "NativeCalculator"
      $end-if    
           goback returning 0.

       entry MFU-TC-TEARDOWN-PREFIX & TEST-MultiplyTest.
           goback returning 0.

       entry MFU-TC-METADATA-SETUP-PREFIX & TEST-MultiplyTest.
           move "This is a example of a dynamic description"
               to MFU-MD-TESTCASE-DESCRIPTION
           move 4000 to MFU-MD-TIMEOUT-IN-MS
           move "smoke" to MFU-MD-TRAITS
           set MFU-MD-SKIP-TESTCASE to false
           goback.
      $end-region
