      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
      * TRANSACTION-RECORD 
       01 (PREFIX)-TRANSACTION-RECORD.
        03 (PREFIX)-TRANSACTION-ID     PIC X(4) COMP-X. 
        03 (PREFIX)-ACCOUNT-ID         PIC X(4) COMP-X. 
        03 (PREFIX)-TRANS-DATE.    *> yyyymmdd
         05 (PREFIX)-YEAR              PIC 9(4).
         05 (PREFIX)-MONTH             PIC 9(2). 
         05 (PREFIX)-DAY               PIC 9(2). 
        03 (PREFIX)-AMOUNT             PIC S9(12)V99. 
        03 (PREFIX)-DESCRIPTION        PIC X(255). 

