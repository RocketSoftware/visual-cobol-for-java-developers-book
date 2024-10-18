      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
      $set ilusing(java.io) 
       class-id com.mfcobolbook.databuilder.MainClass public.
      
       method-id main (args as string occurs any) static.
           declare a as string
           if size of args < 3
               display "Arguments to delete all data and start from fresh:"
               display "-new <directory> <yyyymmdd>"
               display "Arguments to add extra data:"
               display "-add <directory> <yyyymmdd>"
               display "Filenames must include either transaction or customer to be found"
               display "yyyymmdd is the start date for all transaction data."
               goback
           end-if
           declare arguments = new DataBuilderArguments(args)
           invoke process (arguments)
           display "Press Enter to complete"
           accept a

       end method.
       
       method-id process(arguments as type DataBuilderArguments) 
                           static private.
           declare accountsBuilder = new AccountsBuilder(
                                     arguments::dataPaths::customerDataPath)
           declare transactionsBuilder = new TransactionsBuilder(
                                   arguments::dataPaths::transactionDataPath,
                                   arguments::dateString)
           if arguments::operation = type DataBuilderArguments+Operation::initializeData
               invoke accountsBuilder::initializeTables()
               if accountsBuilder::createRecords()
                   display "Customer and account records created"
               else
                   display "Failed creating customer and account records"
                   exit method
               end-if
           end-if
           if transactionsBuilder::createRecords()
                   display "Transaction records created"
           else
               display "Failed creating customer and account records"
           end-if
            
       end method.
       
       end class.
