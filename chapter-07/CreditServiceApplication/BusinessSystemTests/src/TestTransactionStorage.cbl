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
       program-id. TestTransactionStorage.

       environment division.
       configuration section.

       data division.
       working-storage section.
       copy "PROCEDURE-NAMES.cpy".
       copy "FUNCTION-CODES.cpy".
       copy "HELPER-FUNCTIONS.cpy".
       78 TEST-WriteTransaction        value "TestWriteTransaction".
       78 TEST-ReadLastTransaction     value "TestReadLastTransaction". 
       78 TEST-ReadRecordsByAccount    value "TestReadTransactionRecords". 
       78 TEST-UpdateTransaction       value "TestUpdateTransaction". 

       78 FK-CUSTOMER-ID               value 888. 
       78 FK-CUSTOMER-FIRST-NAME       value "Verity.
       78 FK-CUSTOMER-LAST-NAME        value "Talkington". 
       78 FK-BALANCE                   value 400.21. 
       78 FK-TYPE                      value "C". 
       78 FK-CREDIT-LIMIT              value 1000.00. 

       78 FK-ACCOUNT-ID                value 777.
       78 FK-ACCOUNT-ID-2              value 888. 
       78 TEST-TRANSACTION-ID-1        value 100.
       78 TEST-TRANS-DATE-1            value "20190801". 
       78 TEST-AMOUNT-1                value 55.86. 
       78 TEST-DESCRIPTION-1           value "Tigers". 
       78 TEST-TRANSACTION-ID-2        value 101.
       78 TEST-TRANS-DATE-2            value "20190817". 
       78 TEST-AMOUNT-2                value 9.21. 
       78 TEST-DESCRIPTION-2           value "Giraffes".        
       78 TEST-TRANSACTION-ID-3        value 102.
       78 TEST-TRANS-DATE-3            value "20190822". 
       78 TEST-AMOUNT-3                value 3.00. 
       78 TEST-DESCRIPTION-3           value "Antelopes".
       78 TEST-TRANSACTION-ID-4        value 103.
       78 TEST-TRANS-DATE-4            value "20190711". 
       78 TEST-AMOUNT-4                value 5.55. 
       78 TEST-DESCRIPTION-4           value "Gazelles".        
       78 TEST-TRANSACTION-ID-5        value 104.
       78 TEST-TRANS-DATE-5            value "20190712". 
       78 TEST-AMOUNT-5                value 6.70. 
       78 TEST-DESCRIPTION-5           value "Zebras".        
       
       01 WS-ID-TABLE.
        03 WS-ID-ROW               pic x(4) comp-5 OCCURS 3 TIMES. 
       01 i                        pic x(2) comp-5.
       01 msg                      pic x(200). 
       01 function-code            pic x. 
       01 write-mode               pic x. 
       01 file-status.
        03 status-byte-1           pic x.
        03 status-byte-2           pic x.
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by WS.
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by WS.
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by WS.
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by TEST. 
       copy "mfunit.cpy".
       procedure division.

      $region Test Configuration
       entry MFU-TC-SETUP-PREFIX & TEST-ReadLastTransaction. 
       entry MFU-TC-SETUP-PREFIX & TEST-UpdateTransaction.
       entry MFU-TC-SETUP-PREFIX & TEST-WriteTransaction.
       entry MFU-TC-SETUP-PREFIX & TEST-ReadRecordsByAccount.     
           perform setup-transaction-test
           goback returning 0.

      $end-region

       entry MFU-TC-PREFIX & TEST-WriteTransaction.
           if failed perform test-failed end-if  *> checking for failure of setup
           move TEST-TRANSACTION-ID-1 to TEST-TRANSACTION-ID
           move FK-ACCOUNT-ID to TEST-ACCOUNT-ID
           move TEST-AMOUNT-1 to TEST-AMOUNT 
           move TEST-TRANS-DATE-1 to TEST-TRANS-DATE
           move TEST-DESCRIPTION-1 to TEST-DESCRIPTION
           move WRITE-RECORD to write-mode
           perform write-a-transaction-record 
           if failed goback end-if 
           move spaces to WS-TRANSACTION-RECORD
           move TEST-TRANSACTION-ID-1 to WS-TRANSACTION-ID
           call COMPARE-RECORDS using by value 
                                      length of WS-TRANSACTION-RECORD
                                   by reference WS-TRANSACTION-RECORD
                                               TEST-TRANSACTION-RECORD
                                               function-status
           goback returning 0. 
       
       entry MFU-TC-PREFIX & TEST-UpdateTransaction.
           if failed perform test-failed end-if  *> checking for failure of setup
           move TEST-TRANSACTION-ID-1 to TEST-TRANSACTION-ID
           move FK-ACCOUNT-ID to TEST-ACCOUNT-ID
           move TEST-AMOUNT-1 to TEST-AMOUNT 
           move TEST-TRANS-DATE-1 to TEST-TRANS-DATE
           move TEST-DESCRIPTION-1 to TEST-DESCRIPTION
           move WRITE-RECORD to write-mode
           perform write-a-transaction-record 
           move FK-ACCOUNT-ID to TEST-ACCOUNT-ID
           move TEST-AMOUNT-2 to TEST-AMOUNT 
           move TEST-TRANS-DATE-2 to TEST-TRANS-DATE
           move TEST-DESCRIPTION-2 to TEST-DESCRIPTION
           move UPDATE-RECORD to write-mode
           perform write-a-transaction-record
           if failed goback end-if
           move spaces to WS-TRANSACTION-RECORD
           move TEST-TRANSACTION-ID-1 to WS-TRANSACTION-ID
           call COMPARE-RECORDS using by value 
                                      length of WS-TRANSACTION-RECORD
                                   by reference WS-TRANSACTION-RECORD
                                                TEST-TRANSACTION-RECORD
                                                function-status
           goback returning 0. 

       entry MFU-TC-PREFIX & TEST-ReadRecordsByAccount.
           if failed perform test-failed end-if  *> checking for failure of setup
           perform write-multiple-records
           move OPEN-READ to function-code
           call OPEN-TEST-FILE using by value function-code
                                 by reference function-status
           move START-READ to function-code
           move 1 to WS-TRANSACTION-ID
           move FK-ACCOUNT-ID to WS-ACCOUNT-ID of WS-TRANSACTION-RECORD
           call FIND-TRANSACTION-BY-ACCOUNT using by value function-code 
                                    by reference WS-TRANSACTION-RECORD
                                                 file-status
           if file-status <> "00" perform test-failed end-if
           move READ-NEXT to function-code
           perform varying i from 1 by 1 until i  > 4
               call FIND-TRANSACTION-BY-ACCOUNT using by value function-code
                                       by reference WS-TRANSACTION-RECORD
                                                    file-status
               if WS-TRANSACTION-ID <>  WS-ID-ROW(i)
                   move z"Wrong data returned" to msg
                   call MFU-ASSERT-FAIL-Z using msg
                   goback
               end-if
               if file-status = "00" 
                   exit perform
               else if file-status <> "02" 
                  perform test-failed 
               end-if

           end-perform
           if i  < 3 
               move "Only read " & i & z" records" to msg 
               call MFU-ASSERT-FAIL-Z using msg 
           end-if
           call CLOSE-TEST-FILE using by reference function-status 
           goback returning 0. 

       entry MFU-TC-PREFIX & TEST-ReadLastTransaction.
           if failed perform test-failed end-if  *> checking for failure of setup
           perform write-multiple-records
           move OPEN-READ to function-code 
           call OPEN-TEST-FILE using by value function-code 
                                 by reference function-status
           if failed perform test-failed end-if
           move spaces to WS-TRANSACTION-RECORD
           call READ-LAST-TRANSACTION-RECORD using 
                             by reference WS-TRANSACTION-RECORD
                                          file-status
           if file-status <> "00" 
               call MFU-ASSERT-FAIL-Z using z"Could not read last record"
               goback        
           end-if
           move TEST-TRANSACTION-ID-5 to TEST-TRANSACTION-ID 
           move FK-ACCOUNT-ID-2 to TEST-ACCOUNT-ID
           move TEST-AMOUNT-5 to TEST-AMOUNT 
           move TEST-TRANS-DATE-5 to TEST-TRANS-DATE
           move TEST-DESCRIPTION-5 to TEST-DESCRIPTION

           if WS-TRANSACTION-RECORD <> TEST-TRANSACTION-RECORD 
               call MFU-ASSERT-FAIL-Z using z"Last record not found"
           end-if
           goback returning 0. 


       setup-transaction-test section.
           call HELPER-FUNCTIONS
           call INIT-TRANSACTION-TEST using by reference function-status 
           .
       
       write-multiple-records section.
           move OPEN-WRITE to function-code
           call OPEN-TEST-FILE using by value function-code
                                 by reference function-status
           move WRITE-RECORD to function-code
           move TEST-TRANSACTION-ID-1 to TEST-TRANSACTION-ID, WS-ID-ROW(1)
           move FK-ACCOUNT-ID to TEST-ACCOUNT-ID
           move TEST-AMOUNT-1 to TEST-AMOUNT 
           move TEST-TRANS-DATE-1 to TEST-TRANS-DATE
           move TEST-DESCRIPTION-1 to TEST-DESCRIPTION
           call WRITE-TEST-RECORD using by value function-code
                                    by reference TEST-TRANSACTION-RECORD
                                                 function-status
           if failed perform test-failed end-if
           move TEST-TRANSACTION-ID-2 to TEST-TRANSACTION-ID, WS-ID-ROW(2)
           move FK-ACCOUNT-ID to TEST-ACCOUNT-ID
           move TEST-AMOUNT-2 to TEST-AMOUNT 
           move TEST-TRANS-DATE-2 to TEST-TRANS-DATE
           move TEST-DESCRIPTION-2 to TEST-DESCRIPTION
           call WRITE-TEST-RECORD using by value function-code
                                    by reference TEST-TRANSACTION-RECORD
                                                 function-status
           if failed perform test-failed end-if
           move TEST-TRANSACTION-ID-3 to TEST-TRANSACTION-ID, WS-ID-ROW(3)
           move FK-ACCOUNT-ID to TEST-ACCOUNT-ID
           move TEST-AMOUNT-3 to TEST-AMOUNT 
           move TEST-TRANS-DATE-3 to TEST-TRANS-DATE
           move TEST-DESCRIPTION-3 to TEST-DESCRIPTION
           call WRITE-TEST-RECORD using by value function-code
                                    by reference TEST-TRANSACTION-RECORD
                                                 function-status
           
           move TEST-TRANSACTION-ID-4 to TEST-TRANSACTION-ID
           move FK-ACCOUNT-ID-2 to TEST-ACCOUNT-ID
           move TEST-AMOUNT-4 to TEST-AMOUNT 
           move TEST-TRANS-DATE-4 to TEST-TRANS-DATE
           move TEST-DESCRIPTION-4 to TEST-DESCRIPTION
           call WRITE-TEST-RECORD using by value function-code
                                    by reference TEST-TRANSACTION-RECORD
                                                 function-status           
           if failed perform test-failed end-if
           move TEST-TRANSACTION-ID-5 to TEST-TRANSACTION-ID
           move FK-ACCOUNT-ID-2 to TEST-ACCOUNT-ID
           move TEST-AMOUNT-5 to TEST-AMOUNT 
           move TEST-TRANS-DATE-5 to TEST-TRANS-DATE
           move TEST-DESCRIPTION-5 to TEST-DESCRIPTION
           call WRITE-TEST-RECORD using by value function-code
                                    by reference TEST-TRANSACTION-RECORD
                                                 function-status           
           if failed perform test-failed end-if
           call CLOSE-TEST-FILE using by reference function-status
           exit section.
           
       write-a-transaction-record section. 
           move OPEN-I-O to function-code
           call OPEN-TEST-FILE using by value function-code 
                                 by reference function-status
           if failed perform test-failed end-if
           call WRITE-TEST-RECORD using by value write-mode
                                    by reference TEST-TRANSACTION-RECORD
                                                 function-status
           if failed perform test-failed end-if
           call CLOSE-TEST-FILE using by reference function-status
           if failed goback end-if 
           exit section. 
           
           
           exit section. 
       
       test-failed section.
           call MFU-ASSERT-FAIL-Z using by reference z"Test helper function failed" 
           goback. 
