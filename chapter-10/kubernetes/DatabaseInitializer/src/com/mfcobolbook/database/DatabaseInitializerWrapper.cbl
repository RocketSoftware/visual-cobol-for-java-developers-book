      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
      $set ilusing(java.math) ilusing(java.io)
       class-id com.mfcobolbook.database.DatabaseInitializerWrapper public.
       copy "DataMigrationEntryPoints.cpy".
       copy "PROCEDURE-NAMES.cpy".

       method-id New.
           invoke setConnectionString()
       end method.

       method-id dropAndCreateTables.
           call CREATE-TABLES
       end method.

       method-id. loadCustomerData (csvPath as type InputStream).
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by ==WS==.
       01 success pic 9.
           try
               call OPEN-DATABASE using by reference success
               if success <> 0
                   raise new Exception("Could not open database")
               end-if
               declare reader = new CsvReader(csvPath)
               perform varying fields as string occurs any through reader::getRows()
                   set WS-CUSTOMER-ID to type Integer::parseInt(fields(1))
                   set WS-FIRST-NAME to fields(2)
                   set WS-LAST-NAME to fields(3)
                   call WRITE-CUSTOMER-ROW using WS-CUSTOMER-RECORD
                                                 success
                   if (success <> 0)
                       raise new Exception("Could not write row")
                   end-if
               end-perform
           finally
               call CLOSE-DATABASE using by reference success
           end-try
       end method.

       method-id. loadAccountData (csvPath as type InputStream).
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by ==WS==.
       01 success pic 9.
           try
               call OPEN-DATABASE using by reference success
               if success <> 0
                   raise new Exception("Could not open database")
               end-if
               declare reader = new CsvReader(csvPath)
               perform varying fields as string occurs any through reader::getRows()
                   set WS-ACCOUNT-ID to type Integer::parseInt(fields(1))
                   set WS-CUSTOMER-ID to type Integer::parseInt(fields(2))
                   set WS-BALANCE to new BigDecimal(fields(3))
                   set WS-TYPE to fields(4)
                   set WS-CREDIT-LIMIT to type Integer::parseInt(fields(5))
                   call WRITE-ACCOUNT-ROW using by reference WS-ACCOUNT
                                                             success
                   if (success <> 0)
                       raise new Exception("Could not write row")
                   end-if
               end-perform
           finally
               call CLOSE-DATABASE using by reference success
           end-try
       end method.

       method-id. loadTransactionData (csvPath as type InputStream).
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by ==WS==.
       01 success pic 9.
           try
               declare counter = 0
               declare shouldOpen = true
               declare reader = new CsvReader(csvPath)
               perform varying fields as string occurs any through reader::getRows()
                   add 1 to counter
                   if shouldOpen
                       call OPEN-DATABASE using by reference success
                       if success <> 0
                           raise new Exception("Could not open database")
                       end-if
                   end-if
                   set WS-TRANSACTION-ID to type Integer::parseInt(fields(1))
                   set WS-ACCOUNT-ID to type Integer::parseInt(fields(2))
                   set WS-TRANS-DATE to fields(3)
                   set WS-AMOUNT to new BigDecimal(fields(4))
                   set WS-DESCRIPTION to fields(5)
                   call WRITE-TRANSACTION-ROW using WS-TRANSACTION-RECORD
                                                    success
                   if (success <> 0)
                       raise new Exception("Could not write row")
                   end-if
                   if counter b-and h"0ff" = 0 then *> Every 4000 records
                       set shouldOpen to true
                       call CLOSE-DATABASE using by reference success
                       if success <> 0
                           raise new Exception("Could not open database")
                       end-if
                   else
                       set shouldOpen to false
                   end-if

               end-perform
           finally
               call CLOSE-DATABASE using by reference success
           end-try
       end method.

       method-id setConnectionString () static.
       01 fileOpened condition-value.
       78 POSTGRES-HOST value "POSTGRES_HOST".
       78 POSTGRES-DB value "POSTGRES_DB".
       78 POSTGRES-USER value "POSTGRES_USER".
       78 POSTGRES-PASSWORD value "POSTGRES_PASSWORD".
       01 connection-string-arg pic x(300).
           declare no-connection-string = false
           declare template = "Driver=org.postgresql.Driver;URL=jdbc:postgresql://%s/%s?user=%s&password=%s"
           declare pg-host = type System::getenv(POSTGRES-HOST)
           declare pg-db = type System::getenv(POSTGRES-DB)
           declare pg-user = type System::getenv(POSTGRES-USER)
           declare pg-password = type System::getenv(POSTGRES-PASSWORD)
           display POSTGRES-HOST space with no advancing
           if pg-host = null
               set no-connection-string = true
               display "NOT SET" space with no advancing
           else
               display pg-host space with no advancing
           end-if
           display POSTGRES-DB space with no advancing
           if pg-db = null
               set no-connection-string = true
               display "NOT SET" space with no advancing
           else
               display pg-db space with no advancing
           end-if
           display POSTGRES-USER space with no advancing
           if pg-user = null
               set no-connection-string = true
               display "NOT SET" space with no advancing
           else
               display pg-user space with no advancing
           end-if
           display POSTGRES-PASSWORD space with no advancing
           if pg-password = null
               set no-connection-string = true
               display "NOT SET
           else
               display "****"
           end-if

           if no-connection-string
               raise new Exception("Can't set database connection string")
           end-if
           declare connection-string = type String::format(template, pg-host, pg-db, pg-user, pg-password)
           move connection-string to connection-string-arg
           call "DatabaseInitializer" using by reference connection-string-arg
           call "AccountStorageAccess" 
           call SET-DB-CONNECTION-STRING using by reference connection-string-arg
       end method.

       end class.
