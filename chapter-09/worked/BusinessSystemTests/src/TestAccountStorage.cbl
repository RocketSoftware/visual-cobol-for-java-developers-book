      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
       copy "mfunit_prototypes.cpy".
       copy "cblproto.cpy". 
       
       program-id. TestAccountStorage. 

       data division.
       working-storage section.
       copy "PROCEDURE-NAMES.cpy".
       copy "FUNCTION-CODES.cpy".
       copy "HELPER-FUNCTIONS.cpy".
       78 TEST-WriteAccount        value "TestWriteAccount".
       78 TEST-ReadLastAccount     value "TestReadLastAccount". 
       78 TEST-ReadRecords         value "TestReadAccountRecords". 
       78 TEST-UpdateAccount       value "TestUpdateAccount". 
       01 write-mode               pic x. 
       
       78 FK-CUSTOMER-ID           value 888. 
       78 FK-CUSTOMER-FIRST-NAME   value "Verity".
       78 FK-CUSTOMER-LAST-NAME    value "Talkington". 
       
       78 TEST-ID-1                value 200. 
       78 TEST-BALANCE-1           value 400.21. 
       78 TEST-TYPE-1              value "C". 
       78 TEST-CREDIT-LIMIT-1      value 1000.00. 
       78 TEST-ID-2                value 201. 
       78 TEST-BALANCE-2           value 702.31. 
       78 TEST-TYPE-2              value "C". 
       78 TEST-CREDIT-LIMIT-2      value 2000.00. 
       78 TEST-ID-3                value 210. 
       78 TEST-BALANCE-3           value 99.37. 
       78 TEST-TYPE-3              value "C". 
       78 TEST-CREDIT-LIMIT-3      value 750.00. 
       01 WS-ID-TABLE.
        03 WS-ID-ROW               pic x(4) comp-5 OCCURS 3 TIMES. 
       01 i                        pic x(2) comp-5.
       01 msg                      pic x(200). 
       01 function-code            pic x. 
       01 file-status.
        03 status-byte-1           pic x.
        03 status-byte-2           pic x.
       copy "CUSTOMER-RECORD.cpy"  replacing ==(PREFIX)== by WS. 
       copy "ACCOUNT-RECORD.cpy"   replacing ==(PREFIX)== by WS.
       copy "ACCOUNT-RECORD.cpy"   replacing ==(PREFIX)== by TEST. 
       
       copy "mfunit.cpy".
       procedure division.

      $region Test Configuration
       entry MFU-TC-SETUP-PREFIX & TEST-UpdateAccount.
       entry MFU-TC-SETUP-PREFIX & TEST-WriteAccount.
       entry MFU-TC-SETUP-PREFIX & TEST-ReadRecords.
       entry MFU-TC-SETUP-PREFIX & TEST-ReadLastAccount. 
           perform setup-account-test
           goback returning 0.

      $end-region

       entry MFU-TC-PREFIX & TEST-WriteAccount.
           if failed perform test-failed end-if *>  checking for failure of setup
           move TEST-ID-1 to TEST-ACCOUNT-ID
           move FK-CUSTOMER-ID to TEST-CUSTOMER-ID
           move TEST-BALANCE-1 to TEST-BALANCE
           move TEST-TYPE-1 to TEST-TYPE
           move TEST-CREDIT-LIMIT-1 to TEST-CREDIT-LIMIT 
           move WRITE-RECORD to write-mode
           perform write-an-account-record
           if failed perform test-failed end-if  
           move spaces to WS-ACCOUNT
           MOVE TEST-ID-1 to WS-ACCOUNT-ID 
           call COMPARE-RECORDS using by value length of WS-ACCOUNT
                                            by reference WS-ACCOUNT
                                                         TEST-ACCOUNT
                                                         function-status
           goback returning return-code
           .
           
       entry MFU-TC-PREFIX & TEST-UpdateAccount.
           if failed perform test-failed end-if *>  check for setup failure
           move TEST-ID-1 to TEST-ACCOUNT-ID
           move FK-CUSTOMER-ID to TEST-CUSTOMER-ID
           move TEST-BALANCE-1 to TEST-BALANCE
           move TEST-TYPE-1 to TEST-TYPE
           move TEST-CREDIT-LIMIT-1 to TEST-CREDIT-LIMIT 
           move WRITE-RECORD to write-mode
           perform write-an-account-record
           move TEST-BALANCE-2 to TEST-BALANCE 
           move TEST-CREDIT-LIMIT-2 to TEST-CREDIT-LIMIT
           move UPDATE-RECORD to write-mode 
           perform write-an-account-record 
           move spaces to WS-ACCOUNT
           move TEST-ID-1 to WS-ACCOUNT-ID 
           call COMPARE-RECORDS using by value 
                                     length of WS-ACCOUNT
                                  by reference WS-ACCOUNT 
                                               TEST-ACCOUNT
                                               function-status
           goback returning return-code
           . 
           
       entry MFU-TC-PREFIX & TEST-ReadLastAccount. 
           if failed perform test-failed end-if *>  checking for failure of setup
           perform write-multiple-records
           move OPEN-READ to function-code 
           call OPEN-TEST-FILE using by value function-code 
                                 by reference function-status
           if failed perform test-failed end-if
           move spaces to WS-ACCOUNT
           call READ-LAST-ACCOUNT-RECORD using 
                             by reference WS-ACCOUNT
                                          file-status
           if file-status <> "00"
               move zeros to msg 
               move "File status when reading last record " & file-status to msg
               call MFU-ASSERT-FAIL-Z using by reference msg
               goback
           end-if
           move TEST-ID-3 to TEST-ACCOUNT-ID
           move FK-CUSTOMER-ID to TEST-CUSTOMER-ID
           move TEST-BALANCE-3 to TEST-BALANCE
           move TEST-TYPE-3 to TEST-TYPE
           move TEST-CREDIT-LIMIT-3 TO TEST-CREDIT-LIMIT
           if WS-ACCOUNT <> TEST-ACCOUNT 
               call MFU-ASSERT-FAIL-Z using z"Last record not found"
           end-if
           goback returning return-code
           . 
           
       entry MFU-TC-PREFIX & TEST-ReadRecords.
           if failed perform test-failed end-if *>  checking for failure of setup    
           perform write-multiple-records
           if failed perform test-failed end-if
      
           move OPEN-READ to function-code
           call OPEN-TEST-FILE using by value function-code
                                 by reference function-status
           move START-READ to function-code
           move 1 to WS-ACCOUNT-ID
           call READ-TEST-RECORDS using by value function-code 
                                    by reference WS-ACCOUNT
                                                 function-status
           if failed perform test-failed end-if
           move READ-NEXT to function-code
           perform varying i from 1 by 1 until i > 3 
               call READ-TEST-RECORDS using by value function-code
                                       by reference WS-ACCOUNT
                                                    function-status
               if failed perform test-failed end-if 
               if WS-ACCOUNT-ID <>  WS-ID-ROW(i)
                   move z"Wrong data returned" to msg
                   call MFU-ASSERT-FAIL-Z using msg
                   goback
               end-if
           end-perform
           call CLOSE-TEST-FILE using by reference function-status 
           goback returning return-code. 
           
       setup-account-test section.
           call HELPER-FUNCTIONS
           call INIT-ACCOUNT-TEST using by reference function-status
      $if OESQL-TEST = 11    
           perform add-fk-customer
      $end
           goback.

       write-multiple-records section. 
           move OPEN-WRITE to function-code
           call OPEN-TEST-FILE using by value function-code
                                 by reference function-status
           move WRITE-RECORD to function-code
           move TEST-ID-1 to TEST-ACCOUNT-ID, WS-ID-ROW(1)
           move FK-CUSTOMER-ID to TEST-CUSTOMER-ID
           move TEST-BALANCE-1 to TEST-BALANCE
           move TEST-TYPE-1 to TEST-TYPE
           move TEST-CREDIT-LIMIT-1 TO TEST-CREDIT-LIMIT
           call WRITE-TEST-RECORD using by value function-code
                                    by reference TEST-ACCOUNT
                                                 function-status
           if failed perform test-failed end-if
           move WRITE-RECORD to function-code
           move TEST-ID-2 to TEST-ACCOUNT-ID, WS-ID-ROW(2)
           move FK-CUSTOMER-ID to TEST-CUSTOMER-ID
           move TEST-BALANCE-2 to TEST-BALANCE
           move TEST-TYPE-2 to TEST-TYPE
           move TEST-CREDIT-LIMIT-2 TO TEST-CREDIT-LIMIT
           call WRITE-TEST-RECORD using by value function-code
                                    by reference TEST-ACCOUNT
                                                 function-status
           if failed perform test-failed end-if
           move WRITE-RECORD to function-code
           move TEST-ID-3 to TEST-ACCOUNT-ID, WS-ID-ROW(3)
           move FK-CUSTOMER-ID to TEST-CUSTOMER-ID
           move TEST-BALANCE-3 to TEST-BALANCE
           move TEST-TYPE-3 to TEST-TYPE
           move TEST-CREDIT-LIMIT-3 TO TEST-CREDIT-LIMIT
           call WRITE-TEST-RECORD using by value function-code
                                    by reference TEST-ACCOUNT
                                                 function-status
           if failed perform test-failed end-if 
           call CLOSE-TEST-FILE using by reference function-status
           exit section. 
           
      $if OESQL-TEST=11
      *> A customer record is needed as the foreign key to an account
       add-fk-customer section.
           move FK-CUSTOMER-ID to WS-CUSTOMER-ID of WS-CUSTOMER-RECORD 
           move FK-CUSTOMER-FIRST-NAME to WS-FIRST-NAME
           move FK-CUSTOMER-LAST-NAME to WS-LAST-NAME
           call ADD-CUSTOMER using by reference function-status 
                                                 WS-CUSTOMER-RECORD
           if failed perform test-failed end-if
           exit section.  
      $end    
       write-an-account-record section.
           move OPEN-I-O to function-code    
           call OPEN-TEST-FILE using by value function-code 
                            by reference function-status 
           if failed perform test-failed end-if 
           call WRITE-TEST-RECORD using by value write-mode 
                               by reference TEST-ACCOUNT 
                                            function-status
           if failed perform test-failed end-if 
           call CLOSE-TEST-FILE using by reference function-status
           if failed perform test-failed end-if 
           exit section.
       
       test-failed section.
           call MFU-ASSERT-FAIL-Z using by reference z"Test helper function failed" 
           goback. 
