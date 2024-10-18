      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
      $set ilusing(java.io)

       class-id com.mfcobolbook.datamigration.Main public.

       copy "FUNCTION-CODES.cpy". 
       copy "PROCEDURE-NAMES.cpy". 

       method-id main(args as string occurs any) public static.
           if (size of (args) <> 1)
               display "Specify a destination folder"
           end-if

           declare writer = new DataWriter(args(1)) 
           invoke writer::writeCustomers() 
           invoke writer::writeAccounts() 
           invoke writer::writeTransactions() 
       end method. 
       
       end class.
