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

