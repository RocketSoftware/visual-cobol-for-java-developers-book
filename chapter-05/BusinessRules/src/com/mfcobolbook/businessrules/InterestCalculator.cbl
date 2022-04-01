      *****************************************************************
      *                                                               *
      * Copyright (C) 2020-2022 Micro Focus.  All Rights Reserved.    *
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
      
       program-id. InterestCalculator.

       data division.
       working-storage section.
       copy "FUNCTION-CODES.cpy". 
       copy "PROCEDURE-NAMES.cpy".
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by ==WS==.
       01 WS-DEBUG                         PIC 9 VALUE 1. 
       01 WS-DAY-INTEREST                  PIC 9(8)v9(8) comp-3.
       01 WORKING-BALANCE                  PIC S9(12)V9999 comp-3.
       01 DAILY-BALANCE                    PIC S9(12)V99 OCCURS 31.
       01 DAILY-BALANCE-INDEX              PIC 99 COMP-5.
       01 FUNCTION-CODE                    PIC X. 
       01 INTEREST-PAYABLE                 PIC S9(12)V9(8) COMP-3.
       01 FILE-STATUS.
        03 FILE-STATUS-BYTE-1              PIC X.
        03 FILE-STATUS-BYTE-2              PIC X.
       01 DAYS-IN-MONTH                    PIC 99 COMP-5. 
       01 DISPLAY-CASH                     PIC -Z(12)9.99. 
       
       linkage section. 
       copy "DATE.cpy" replacing ==(PREFIX)== BY ==LNK-START==. 

       01 LNK-DAY-RATE                     PIC 99v9(8) comp-3.
       01 LNK-ACCOUNT-ID                   PIC X(4) COMP-X. 
       01 LNK-AMOUNT                       PIC S9(12)V99.
       01 LNK-MINIMUM-PAYMENT              PIC S9(12)V99.
       01 LNK-INTEREST                     PIC S9(12)V99.
       01 LNK-STATUS.
        03 LNK-FILE-STATUS-1               PIC X.
        03 LNK-FILE-STATUS-2               PIC X.

       procedure division.
           goback.
           
      *****************************************************************
      * LNK-DAY-RATE   - Daily interest rate
      * LNK-START-DATE - Assumed to be first of month.
      * LNK-AMOUNT     - on entry: Start balance
      *                  on exit:  Total balance excluding interest
      * LNK-INTEREST     Interest payable 
      *****************************************************************
           ENTRY CALCULATE-INTEREST using by value LNK-START-DATE 
                                                   LNK-ACCOUNT-ID
                                      by reference LNK-DAY-RATE LNK-AMOUNT 
                                                   LNK-INTEREST
                                                   LNK-MINIMUM-PAYMENT
                                                   LNK-STATUS.

      *    INITIALIZE DATA
           perform DISPLAY-START
           perform varying DAILY-BALANCE-INDEX FROM 1 by 1 
                                         until DAILY-BALANCE-INDEX > 31
               move zero to DAILY-BALANCE(DAILY-BALANCE-INDEX)
           end-perform 
           move LNK-AMOUNT to WORKING-BALANCE
           move "00" to LNK-STATUS

           call GET-DAYS-IN-MONTH using by reference LNK-START-DATE 
                                                     DAYS-IN-MONTH
 
      *    OPEN TRANSACTION FILE
           move OPEN-READ to FUNCTION-CODE
           call OPEN-TRANSACTION-FILE using by value FUNCTION-CODE
                                        by reference FILE-STATUS
           if FILE-STATUS <> "00"
               move FILE-STATUS to LNK-STATUS
               goback 
           end-if

      *>   INITIALIZE READ FOR SELECTED ACCOUNT
           move LNK-ACCOUNT-ID to WS-ACCOUNT-ID
           move 0 to WS-TRANSACTION-ID 
           move START-READ to FUNCTION-CODE
           call FIND-TRANSACTION-BY-ACCOUNT using by value FUNCTION-CODE
                                      by reference WS-TRANSACTION-RECORD
                                                             FILE-STATUS
           if FILE-STATUS <> "00"
               move FILE-STATUS to LNK-STATUS
               perform CLOSE-TRANSACTION-FILE
               goback 
           end-if

           
      *    First loop: 
      *    Read all transactions for month, and 
      *    Add each day's transactions to the balance for that day.
           move READ-NEXT to FUNCTION-CODE
           move "99" to FILE-STATUS 
           perform until FILE-STATUS = "00" 
               call FIND-TRANSACTION-BY-ACCOUNT using 
                                             by value FUNCTION-CODE
                                         by reference WS-TRANSACTION-RECORD
                                                                FILE-STATUS
               if FILE-STATUS <> "00" and FILE-STATUS <> "02"
                   exit perform *> unexpected status
               end-if
               if WS-MONTH <> LNK-START-MONTH OR WS-YEAR <> LNK-START-YEAR
      *            IGNORE TRANSACTIONS FOR OTHER MONTHS 
                   exit perform cycle
               end-if
               perform DISPLAY-TRANSACTION
               move WS-DAY to DAILY-BALANCE-INDEX     
               add WS-AMOUNT to DAILY-BALANCE(DAILY-BALANCE-INDEX)
           end-perform

           if FILE-STATUS <> "00" and FILE-STATUS <> "10" 
      *>       FILE-STATUS "10" = No records found for account                
      *            and FILE-STATUS <> "23"
      *            and FILE-STATUS <> "10"
      *        Unexpected file status - can't complete calculation     
               move FILE-STATUS to LNK-STATUS
               perform CLOSE-TRANSACTION-FILE
               goback 
           end-if

      *    PERFORM INTEREST CALCULATION
      *    Second loop: for each day in the month calculate running 
      *    total, and calculate interest for each day. 
           add WORKING-BALANCE to DAILY-BALANCE(1)
           move 0 to INTEREST-PAYABLE 
           perform varying DAILY-BALANCE-INDEX from 1 by 1
                     until DAILY-BALANCE-INDEX > DAYS-IN-MONTH
      *        calculate the daily interest and add it to the daily balance          
               multiply DAILY-BALANCE(DAILY-BALANCE-INDEX) by LNK-DAY-RATE 
                 giving WS-DAY-INTEREST
               add WS-DAY-INTEREST to DAILY-BALANCE(DAILY-BALANCE-INDEX), 
                                      INTEREST-PAYABLE
               if DAILY-BALANCE-INDEX < DAYS-IN-MONTH
      *            Balance for next day starts with current day balance          
                   add  DAILY-BALANCE(DAILY-BALANCE-INDEX) 
                       to DAILY-BALANCE(DAILY-BALANCE-INDEX + 1)
               end-if
           end-perform
           move INTEREST-PAYABLE to LNK-INTEREST
      *    Last daily balance is now total for month     
           move DAILY-BALANCE(DAYS-IN-MONTH) to LNK-AMOUNT
           multiply LNK-AMOUNT by .05 giving LNK-MINIMUM-PAYMENT 
           if LNK-MINIMUM-PAYMENT < 5 and WORKING-BALANCE > 5
               move 5 to LNK-MINIMUM-PAYMENT
           else if WORKING-BALANCE < 5
                    move WORKING-BALANCE to LNK-MINIMUM-PAYMENT
                end-if
           end-if
           perform DISPLAY-RESULT
           perform CLOSE-TRANSACTION-FILE     
           goback.

       DISPLAY-TRANSACTION SECTION.
           if WS-DEBUG > 1 
               move WS-AMOUNT to DISPLAY-CASH
               display "AC=" WS-ACCOUNT-ID ", " with no advancing
               display "TId=" WS-TRANSACTION-ID ", " with no advancing
               display WS-DAY "," with no advancing
               display DISPLAY-CASH "," with no advancing
               display WS-DESCRIPTION
           end-if
           .
       DISPLAY-START SECTION. 
           if WS-DEBUG > 0
               move LNK-AMOUNT to DISPLAY-CASH
               display "*** Statement for account " with no advancing 
               display LNK-ACCOUNT-ID with no advancing
               display " Start value " DISPLAY-CASH
           end-if
           .
       DISPLAY-RESULT SECTION. 
           if WS-DEBUG > 1
               add 0 to LNK-INTEREST giving DISPLAY-CASH rounded 
               display "account " lnk-account-id " Interest " DISPLAY-CASH
           end-if
           .
       CLOSE-TRANSACTION-FILE SECTION.
           move CLOSE-FILE to FUNCTION-CODE
           CALL OPEN-TRANSACTION-FILE using by value FUNCTION-CODE 
                                        BY reference FILE-STATUS
           .          
           
       
