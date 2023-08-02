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
      
      $set ilusing(java.math) ilusing(java.io) 
       class-id com.mfcobolbook.database.DatabaseInitializerWrapper public.
       copy "DataMigrationEntryPoints.cpy". 

       method-id New.
           call "DatabaseInitializer"
       end method. 
           
       method-id dropAndCreateTables. 
           call CREATE-TABLES 
       end method. 
                 
       method-id. loadCustomerData(csvPath as type InputStream).
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by ==WS==.
       01 success          pic 9. 
       try 
           call OPEN-DATABASE using by reference success 
           if success <> 0 
               raise new Exception ("Could not open database")
           end-if
           declare reader = new CsvReader(csvPath)
           perform varying fields as string occurs any through reader::getRows()
               set WS-CUSTOMER-ID to type Integer::parseInt(fields(1))
               set WS-FIRST-NAME to fields(2)
               set WS-LAST-NAME to fields(3)
               call WRITE-CUSTOMER-ROW using WS-CUSTOMER-RECORD success
               if (success <> 0)
                   raise new Exception( "Could not write row" )
               end-if
           end-perform
       finally 
           call CLOSE-DATABASE using by reference success     
       end-try
       end method. 

       method-id. loadAccountData(csvPath as type InputStream).
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by ==WS==.
       01 success          pic 9. 
       try 
           call OPEN-DATABASE using by reference success 
           if success <> 0 
               raise new Exception ("Could not open database")
           end-if
           declare reader = new CsvReader(csvPath)
           perform varying fields as string occurs any through reader::getRows()
               set WS-ACCOUNT-ID to type Integer::parseInt(fields(1))
               set WS-CUSTOMER-ID to type Integer::parseInt(fields(2))
               set WS-BALANCE to new BigDecimal(fields(3)) 
               set WS-TYPE to fields(4)
               set WS-CREDIT-LIMIT to type Integer::parseInt(fields(5)) 
               call WRITE-ACCOUNT-ROW using by reference WS-ACCOUNT success
               if (success <> 0)
                   raise new Exception( "Could not write row" )
               end-if
           end-perform
       finally 
           call CLOSE-DATABASE using by reference success     
       end-try
       end method. 

       method-id. loadTransactionData(csvPath as type InputStream).
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by ==WS==.
       01 success          pic 9. 
       try 
           declare counter = 0 
           declare shouldOpen = true 
           declare reader = new CsvReader(csvPath)
           perform varying fields as string occurs any through reader::getRows()
               add 1 to counter 
               if shouldOpen
                   call OPEN-DATABASE using by reference success
                   if success <> 0 
                       raise new Exception ("Could not open database")
                   end-if
               end-if
               set WS-TRANSACTION-ID to type Integer::parseInt(fields(1))
               set WS-ACCOUNT-ID to type Integer::parseInt(fields(2))
               set WS-TRANS-DATE to fields(3)
               set WS-AMOUNT to new BigDecimal(fields(4)) 
               set WS-DESCRIPTION to fields(5)
               call WRITE-TRANSACTION-ROW using WS-TRANSACTION-RECORD success
               if (success <> 0)
                   raise new Exception( "Could not write row" )
               end-if
               if counter b-and h"0ff" = 0 then *> Every 4000 records 
                   set shouldOpen to true
                   call CLOSE-DATABASE using by reference success
                   if success <> 0 
                       raise new Exception ("Could not open database")
                   end-if
               else 
                   set shouldOpen to false
               end-if

           end-perform
       finally 
           call CLOSE-DATABASE using by reference success     
       end-try
       end method. 
       end class.
