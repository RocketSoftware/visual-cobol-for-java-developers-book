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
