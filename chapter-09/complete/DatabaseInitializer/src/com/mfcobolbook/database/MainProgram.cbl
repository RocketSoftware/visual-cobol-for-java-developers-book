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
      
       class-id com.mfcobolbook.database.MainProgram public.
       COPY "DataMigrationEntryPoints.cpy". 

       method-id main(args as string occurs any) public static.
           if (size of (args) <> 1)
               display "Specify a destination folder"
           end-if
           call "DatabaseInitializer"
           
           call CREATE-TABLES 
           
           call BULK-COPY using "customer" "c:\temp\csvs\customer.csv"
           call BULK-COPY using "account"  "c:\temp\csvs\account.csv"
           call BULK-COPY using "transaction"  "c:\temp\csvs\transaction.csv"

       end method. 
       
       end class.
