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
       copy "cblproto.cpy". 
       program-id. TestCustomerStorage.

       working-storage section.
       copy "PROCEDURE-NAMES.cpy".
       copy "FUNCTION-CODES.cpy".
       copy "HELPER-FUNCTIONS.cpy". 
       78 TEST-WriteCustomer       value "TestWriteCustomer".
       78 TEST-ReadLastCustomer    value "TestReadLastCustomer". 
       78 TEST-ReadRecords         value "TestReadRecords". 
       78 TEST-UpdateCustomer      value "TestUpdateCustomer". 
       78 TEST-FindCustomerName    value "TestFindCustomerName".
       
       78 TEST-ID-1                value 100. 
       78 TEST-FIRST-NAME-1        value "Fred".
       78 TEST-LAST-NAME-1         value "Flintstone".
       78 TEST-ID-2                value 101. 
       78 TEST-FIRST-NAME-2        value "Barney". 
       78 TEST-LAST-NAME-2         value "Rubble".
       78 TEST-ID-3                value 110. 
       78 TEST-FIRST-NAME-3        value "Sarah". 
       78 TEST-LAST-NAME-3         value "Connor".
       
       01 WS-ID-TABLE.
        03 WS-ID-ROW               pic x(4) comp-5 OCCURS 3 TIMES. 
       01 i                        pic x(2) comp-5.
       01 msg                      pic x(200). 
       01 function-code            pic x. 
       01 write-mode               pic x. 
       01 file-status.
        03 status-byte-1           pic x.
        03 status-byte-2           pic x.
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by WS.
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by TEST. 
       
       copy "mfunit.cpy".
       procedure division.

      $region Test Configuration
       entry MFU-TC-SETUP-PREFIX & TEST-UpdateCustomer.
       entry MFU-TC-SETUP-PREFIX & TEST-WriteCustomer.
       entry MFU-TC-SETUP-PREFIX & TEST-ReadLastCustomer. 
       entry MFU-TC-SETUP-PREFIX & TEST-FindCustomerName. 
       entry MFU-TC-SETUP-PREFIX & TEST-ReadRecords.     
           perform setup-customer-test
           goback returning 0.
  
      $end-region

       entry MFU-TC-PREFIX & TEST-WriteCustomer.
           if failed perform test-failed end-if  *> checking for failure of setup
           move TEST-ID-1 to TEST-CUSTOMER-ID
           move "fred" to TEST-FIRST-NAME
           move "flintstone" to TEST-LAST-NAME
           move WRITE-RECORD to write-mode
           perform write-a-customer-record
           if failed perform test-failed end-if 
           move spaces to WS-CUSTOMER-RECORD
           move TEST-ID-1 to WS-CUSTOMER-ID
                               
           call COMPARE-RECORDS using by value length of WS-CUSTOMER-RECORD
                                            by reference WS-CUSTOMER-RECORD
                                                         TEST-CUSTOMER-RECORD  
                                                         function-status
           goback returning return-code
           .
           
       entry MFU-TC-PREFIX & TEST-UpdateCustomer.
           if failed perform test-failed end-if  *> checking for failure of setup
           move TEST-ID-1 to TEST-CUSTOMER-ID
           move "fred" to TEST-FIRST-NAME
           move "flintstone" to TEST-LAST-NAME
           move WRITE-RECORD to write-mode
           perform write-a-customer-record
           move "Barney" to TEST-FIRST-NAME
           move "Rubble" to TEST-LAST-NAME
           move UPDATE-RECORD to write-mode
           perform write-a-customer-record 
           if failed perform test-failed end-if
           move spaces to WS-CUSTOMER-RECORD
           move TEST-ID-1 to WS-CUSTOMER-ID
           call COMPARE-RECORDS using by value 
                                      length of WS-CUSTOMER-RECORD
                                   by reference WS-CUSTOMER-RECORD
                                                TEST-CUSTOMER-RECORD  
                                                function-status
           goback returning return-code. 
           
       entry MFU-TC-PREFIX & Test-ReadLastCustomer.
           if failed perform test-failed end-if *> checking for failure of setup
           perform write-multiple-records
           move OPEN-READ to function-code 
           call OPEN-TEST-FILE using by value function-code 
                                 by reference function-status
           if failed perform test-failed end-if
           move spaces to WS-CUSTOMER-RECORD
           call READ-LAST-CUSTOMER-RECORD using 
                             by reference WS-CUSTOMER-RECORD
                                          file-status
           if file-status <> "00" 
               call MFU-ASSERT-FAIL-Z using by reference 
                                  z"Failure reading last customer  record"  
                                  
           end-if
           move TEST-ID-3 to TEST-CUSTOMER-ID
           move TEST-FIRST-NAME-3 to TEST-FIRST-NAME
           move TEST-LAST-NAME-3 to TEST-LAST-NAME
           if WS-CUSTOMER-RECORD <> TEST-CUSTOMER-RECORD 
               call MFU-ASSERT-FAIL-Z using z"Last record not found"
           end-if
           goback returning return-code. 
           
       entry MFU-TC-PREFIX & TEST-FindCustomerName. 
           if failed perform test-failed end-if *> checking for failure of setup
           perform write-multiple-records
           move OPEN-READ to function-code 
           call OPEN-TEST-FILE using by value function-code 
                                 by reference function-status
           move spaces to WS-CUSTOMER-RECORD 
           move TEST-LAST-NAME-2 to WS-LAST-NAME
           move START-READ to function-code
           perform until exit 
               call FIND-CUSTOMER-NAME using by value function-code 
                                         by reference WS-CUSTOMER-RECORD
                                                      file-status
               if file-status <> "00" 
                   move "find record failed with status " & file-status & x"00" to msg 
                   call MFU-ASSERT-FAIL-Z using msg 
                   goback 
               end-if
               if function-code = READ-NEXT 
                   exit perform 
               end-if
               move READ-NEXT to function-code
           end-perform
           call CLOSE-TEST-FILE using by reference function-status
           if TEST-ID-2 <> WS-CUSTOMER-ID or
              TEST-FIRST-NAME-2 <> WS-FIRST-NAME or 
              TEST-LAST-NAME-2  <> WS-LAST-NAME
               move z"Records do not match" to msg
               call MFU-ASSERT-FAIL using msg 
           end-if
           goback returning return-code. 
           
       entry MFU-TC-PREFIX & TEST-ReadRecords.
           if failed perform test-failed end-if *> checking for failure of setup
           perform write-multiple-records
           
           move OPEN-READ to function-code 
           call OPEN-TEST-FILE using by value function-code
                                by reference function-status
           move START-READ to function-code
           move 1 to WS-CUSTOMER-ID 
           call READ-TEST-RECORDS using by value function-code
                                    by reference WS-CUSTOMER-RECORD
                                                 function-status
           if failed perform test-failed end-if
           move READ-NEXT to function-code
           perform varying i from 1 by 1 until i > 3 
               call READ-TEST-RECORDS using by value function-code
                                       by reference WS-CUSTOMER-RECORD
                                                    function-status
               if failed perform test-failed end-if 
               if WS-CUSTOMER-ID <>  WS-ID-ROW(i)
                   move z"Wrong data returned" to msg
                   call MFU-ASSERT-FAIL-Z using msg
                   goback
               end-if
           end-perform
           
           call CLOSE-TEST-FILE using by reference function-status 
           goback returning return-code. 

       setup-customer-test section.
           call HELPER-FUNCTIONS
           call INIT-CUSTOMER-TEST using by reference function-status 
           .

       write-multiple-records section. 
           move OPEN-WRITE to function-code    
           call OPEN-TEST-FILE using by value function-code 
                            by reference function-status 
           move WRITE-RECORD to function-code
           move TEST-ID-1 to TEST-CUSTOMER-ID, WS-ID-ROW(1) 
           move TEST-FIRST-NAME-1 to TEST-FIRST-NAME
           move TEST-LAST-NAME-1 to TEST-LAST-NAME
           call WRITE-TEST-RECORD using by value function-code
                                    by reference TEST-CUSTOMER-RECORD
                                                 function-status
           if failed perform test-failed end-if 
           move TEST-ID-2 to TEST-CUSTOMER-ID, WS-ID-ROW(2) 
           move TEST-FIRST-NAME-2 to TEST-FIRST-NAME
           move TEST-LAST-NAME-2 to TEST-LAST-NAME
           call WRITE-TEST-RECORD using by value function-code
                                    by reference TEST-CUSTOMER-RECORD
                                                 function-status
           if failed perform test-failed end-if 
           move TEST-ID-3 to TEST-CUSTOMER-ID, WS-ID-ROW(3) 
           move TEST-FIRST-NAME-3 to TEST-FIRST-NAME
           move TEST-LAST-NAME-3 to TEST-LAST-NAME
           call WRITE-TEST-RECORD using by value function-code
                                    by reference TEST-CUSTOMER-RECORD
                                                 function-status
           if failed perform test-failed end-if 
           call CLOSE-TEST-FILE using by reference function-status
           exit section. 
           
       write-a-customer-record section.
           move OPEN-WRITE to function-code    
           call OPEN-TEST-FILE using by value function-code 
                            by reference function-status 
           if failed perform test-failed end-if 
           call WRITE-TEST-RECORD using by value write-mode 
                               by reference TEST-CUSTOMER-RECORD
                                            function-status
           if failed perform test-failed end-if 
           call CLOSE-TEST-FILE using by reference function-status
           if failed perform test-failed end-if 
           exit section. 
           
       test-failed section.
           call MFU-ASSERT-FAIL-Z using by reference z"Test helper function failed" 
           goback. 
