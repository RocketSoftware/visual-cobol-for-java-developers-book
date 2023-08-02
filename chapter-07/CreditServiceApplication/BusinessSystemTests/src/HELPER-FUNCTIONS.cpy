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
      
       
       
      


