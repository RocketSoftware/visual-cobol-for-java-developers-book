       copy "mfunit_prototypes.cpy".
       
       identification division.
       program-id. TestInterestCalculator as "TestInterestCalculator".

       environment division.
       configuration section.

       data division.
       working-storage section.
       copy "mfunit.cpy".
       copy "PROCEDURE-NAMES.cpy".
       copy "FUNCTION-CODES.cpy".
       copy "HELPER-FUNCTIONS.cpy".
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by ==TEST==.
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by ==TEST==.
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by ==TEST==.
       copy "DATE.cpy" replacing ==(PREFIX)== by ==WS==. 
       01 function-code            pic x. 

       01 WS-DAY-RATE                  PIC 99v9(8) comp-3.
       01 WS-ACCOUNT-ID                PIC X(4) COMP-X. 
       01 WS-AMOUNT                    PIC S9(12)V99.
       01 WS-MINIMUM-PAYMENT           PIC S9(12)V99.
       01 WS-INTEREST                  PIC S9(12)V99.
       01 WS-STATUS.
        03 WS-FILE-STATUS-1            PIC X.
        03 WS-FILE-STATUS-2            PIC X.
       01 msg                          pic x(128). 
       78 START-AMOUNT                 value 300.  

       78 TEST-TestInterestCalculation 
                       value "TestInterestCalculation".
       78 TEST-TestZeroInterestCalculation 
                       value "TestZeroInterestCalculation".
       78 TEST-NoTransactionsCalculation
                       value "TestNoTransactionsCalculation".
       78 TEST-ZeroBalanceTransactionsCalculation
                       value "TestZeroBalanceAndTransactionsCalculation".
        
      *> Test constants
       78 FK-ACCOUNT-ID                value 777. 
       78 FK-CUSTOMER-ID               value 888. 

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
      $if OESQL-TEST = 1 
       78 FK-CUSTOMER-ID               value 888. 
       78 FK-CUSTOMER-FIRST-NAME       value "Verity.
       78 FK-CUSTOMER-LAST-NAME        value "Talkington". 
       78 FK-BALANCE                   value 400.21. 
       78 FK-TYPE                      value "C". 
       78 FK-CREDIT-LIMIT              value 1000.00. 
      $end

       procedure division.

       entry MFU-TC-PREFIX & TEST-TestInterestCalculation.
           if failed perform setup-failed end-if
           divide 1 by 3650 giving WS-DAY-RATE *> 10% interest rate
           move "20190801" to TEST-TRANS-DATE
           move START-AMOUNT to WS-AMOUNT
           move FK-ACCOUNT-ID to WS-ACCOUNT-ID
           call CALCULATE-INTEREST using by value TEST-TRANS-DATE
                                                  WS-ACCOUNT-ID
                                     by reference WS-DAY-RATE 
                                                  WS-AMOUNT
                                                  WS-INTEREST
                                                  WS-MINIMUM-PAYMENT
                                                  WS-STATUS
           if WS-STATUS <> "00" 
               move "File Status of " & WS-STATUS & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           if WS-MINIMUM-PAYMENT <> 18.55 
               move "Expected Minimum payment 18.55, actual " 
                     & WS-MINIMUM-PAYMENT & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           if WS-AMOUNT <> 371.01 
               move "Expected balance 371.01, actual " 
                     & WS-MINIMUM-PAYMENT & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           if WS-INTEREST <> 3.08 
               move "Expected interest 371.01, actual " 
                     & WS-INTEREST & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           goback. 
       
       entry MFU-TC-PREFIX & TEST-TestZeroInterestCalculation.
           if failed perform setup-failed end-if
           move 0 to WS-DAY-RATE 
           move "20190801" to TEST-TRANS-DATE
           move START-AMOUNT to WS-AMOUNT
           move FK-ACCOUNT-ID to WS-ACCOUNT-ID
           call CALCULATE-INTEREST using by value TEST-TRANS-DATE
                                                  WS-ACCOUNT-ID
                                     by reference WS-DAY-RATE 
                                                  WS-AMOUNT
                                                  WS-INTEREST
                                                  WS-MINIMUM-PAYMENT
                                                  WS-STATUS
           if WS-STATUS <> "00" 
               move "File Status of " & WS-STATUS & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           if WS-MINIMUM-PAYMENT <> 18.40
               move "Expected Minimum payment 18.55, actual " 
                     & WS-MINIMUM-PAYMENT & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           if WS-AMOUNT <> 368.07 
               move "Expected balance 371.01, actual " 
                     & WS-AMOUNT & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           if WS-INTEREST <> 0 
               move "Expected interest 0, actual " 
                     & WS-INTEREST & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           goback. 
       
       entry MFU-TC-PREFIX & TEST-NoTransactionsCalculation.
           if failed perform setup-failed end-if
           divide 1 by 3650 giving WS-DAY-RATE *> 10% interest rate
           move "20190701" to TEST-TRANS-DATE
           move START-AMOUNT to WS-AMOUNT
           move FK-ACCOUNT-ID to WS-ACCOUNT-ID
           call CALCULATE-INTEREST using by value TEST-TRANS-DATE
                                                  WS-ACCOUNT-ID
                                     by reference WS-DAY-RATE 
                                                  WS-AMOUNT
                                                  WS-INTEREST
                                                  WS-MINIMUM-PAYMENT
                                                  WS-STATUS
           if WS-STATUS <> "00" 
               move "File Status of " & WS-STATUS & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           if WS-MINIMUM-PAYMENT <> 15.12
               move "Expected Minimum payment 15.12, actual " 
                     & WS-MINIMUM-PAYMENT & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           if WS-AMOUNT <> 302.48 
               move "Expected balance 302.48, actual " 
                     & WS-AMOUNT & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           if WS-INTEREST <> 2.55 
               move "Expected interest 2.55, actual " 
                     & WS-INTEREST & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           goback. 

       entry MFU-TC-PREFIX & TEST-ZeroBalanceTransactionsCalculation.
           if failed perform setup-failed end-if
           divide 1 by 3650 giving WS-DAY-RATE *> 10% interest rate
           move "20190701" to TEST-TRANS-DATE
           move 0 to WS-AMOUNT
           move FK-ACCOUNT-ID to WS-ACCOUNT-ID
           call CALCULATE-INTEREST using by value TEST-TRANS-DATE
                                                  WS-ACCOUNT-ID
                                     by reference WS-DAY-RATE 
                                                  WS-AMOUNT
                                                  WS-INTEREST
                                                  WS-MINIMUM-PAYMENT
                                                  WS-STATUS
           if WS-STATUS <> "00" 
               move "File Status of " & WS-STATUS & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           if WS-MINIMUM-PAYMENT <> 0
               move "Expected Minimum payment 0, actual " 
                     & WS-MINIMUM-PAYMENT & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           if WS-AMOUNT <> 0 
               move "Expected balance 0, actual " 
                     & WS-AMOUNT & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           if WS-INTEREST <> 0 
               move "Expected interest 3, actual " 
                     & WS-INTEREST & x"00" to msg
               call MFU-ASSERT-FAIL-Z using msg
           end-if
           goback. 


       
      $region Test Configuration
       entry MFU-TC-SETUP-PREFIX & TEST-TestInterestCalculation.
       entry MFU-TC-SETUP-PREFIX & TEST-TestZeroInterestCalculation
       entry MFU-TC-SETUP-PREFIX & TEST-NoTransactionsCalculation.
       entry MFU-TC-SETUP-PREFIX & TEST-ZeroBalanceTransactionsCalculation.     
           perform test-setup     
      $if OESQL-TEST = 1    
           perform add-fk-records
      $end    
           perform write-multiple-records 
           goback. 
           

       test-setup section. 
           call "INTEREST-CALCULATOR"
           call HELPER-FUNCTIONS
           call INIT-TRANSACTION-TEST using by reference function-status 
           if failed perform setup-failed end-if 
           .

       write-multiple-records section.
           move OPEN-WRITE to function-code
           call OPEN-TEST-FILE using by value function-code
                                 by reference function-status
           move WRITE-RECORD to function-code
           move TEST-TRANSACTION-ID-1 to TEST-TRANSACTION-ID
           move FK-ACCOUNT-ID to TEST-ACCOUNT-ID of TEST-TRANSACTION-RECORD 
           move TEST-AMOUNT-1 to TEST-AMOUNT 
           move TEST-TRANS-DATE-1 to TEST-TRANS-DATE
           move TEST-DESCRIPTION-1 to TEST-DESCRIPTION
           call WRITE-TEST-RECORD using by value function-code
                                    by reference TEST-TRANSACTION-RECORD
                                                 function-status
           if failed perform test-failed end-if
           move TEST-TRANSACTION-ID-2 to TEST-TRANSACTION-ID
           move FK-ACCOUNT-ID to TEST-ACCOUNT-ID of TEST-TRANSACTION-RECORD
           move TEST-AMOUNT-2 to TEST-AMOUNT 
           move TEST-TRANS-DATE-2 to TEST-TRANS-DATE
           move TEST-DESCRIPTION-2 to TEST-DESCRIPTION
           call WRITE-TEST-RECORD using by value function-code
                                    by reference TEST-TRANSACTION-RECORD
                                                 function-status
           if failed perform test-failed end-if
           move TEST-TRANSACTION-ID-3 to TEST-TRANSACTION-ID
           move FK-ACCOUNT-ID to TEST-ACCOUNT-ID of TEST-TRANSACTION-RECORD
           move TEST-AMOUNT-3 to TEST-AMOUNT 
           move TEST-TRANS-DATE-3 to TEST-TRANS-DATE
           move TEST-DESCRIPTION-3 to TEST-DESCRIPTION
           call WRITE-TEST-RECORD using by value function-code
                                    by reference TEST-TRANSACTION-RECORD
                                                 function-status
           if failed perform test-failed end-if
           call CLOSE-TEST-FILE using by reference function-status
           .
      $if OESQL-TEST=1
      *> A customer record is needed as the foreign key to an account 
      *> and an account record is neeed as the foreign key to a transaction
       add-fk-records section.
           move FK-CUSTOMER-ID to TEST-CUSTOMER-ID 
                               of TEST-CUSTOMER-RECORD
           move FK-CUSTOMER-FIRST-NAME to TEST-FIRST-NAME
           move FK-CUSTOMER-LAST-NAME to TEST-LAST-NAME
           call ADD-CUSTOMER using by reference function-status 
                                                 TEST-CUSTOMER-RECORD
           
           if failed perform test-failed end-if
           move FK-ACCOUNT-ID to TEST-ACCOUNT-ID of TEST-ACCOUNT
           move FK-CUSTOMER-ID to TEST-CUSTOMER-ID of TEST-ACCOUNT
           move FK-BALANCE to TEST-BALANCE
           move FK-CREDIT-LIMIT to TEST-CREDIT-LIMIT
           move FK-TYPE  to TEST-TYPE
           call ADD-ACCOUNT using by reference function-status
                                               TEST-ACCOUNT
           if failed perform test-failed end-if
           exit section.  
      $end    

       setup-failed section.
           call MFU-ASSERT-FAIL-Z using by reference z"Test setup failed" 
           goback. 


       test-failed section.
           call MFU-ASSERT-FAIL-Z using 
                           by reference z"Test helper function failed"
           goback. 



      $end-region

