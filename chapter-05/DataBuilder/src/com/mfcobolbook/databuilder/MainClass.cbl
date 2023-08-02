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
