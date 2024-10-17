      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
       01 function-status          pic 9.
        88 failed                  value 0. 
        88 succeeded               value 1.
        88 no-more-records         value 2. 
      * PROCEDURE-NAMES 
       78 HELPER-FUNCTIONS         value "HELPER-FUNCTIONS". 
       78 OPEN-TEST-FILE           value "OPEN-FILE".
       78 WRITE-TEST-RECORD        value "WRITE-TEST-RECORD".
       78 DELETE-TEST-RECORD       value "DELETE-TEST-RECORD".
       78 READ-TEST-RECORDS        value "READ-TEST-RECORDS". 
       78 READ-LAST-TEST-RECORD    value "READ-LAST-TEST-RECORD".
       78 VERIFY-TEST-RECORD       value "VERIFY-RECORD".
       78 CLOSE-TEST-FILE          value "CLOSE-FILE"
       78 COMPARE-RECORDS          value "COMPARE-RECORDS".
       78 INIT-CUSTOMER-TEST       value "SET-CUSTOMER-POINTERS".
       78 INIT-ACCOUNT-TEST        value "SET-ACCOUNT-POINTERS".
       78 INIT-TRANSACTION-TEST    value "SET-TRANSACTION-POINTERS".
      
       
       
      


