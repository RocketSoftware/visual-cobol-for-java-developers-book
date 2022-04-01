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
      
       class-id com.mfcobolbook.databuilder.AbstractBuilder public abstract.

       working-storage section.
       copy "PROCEDURE-NAMES.cpy". 
       01 inputFile            string protected.
       01 openAccountFile      procedure-pointer.
       01 openCustomerFile     procedure-pointer.
       01 openTransactionFile  procedure-pointer. 

       


       method-id new (inputFile as string) public.
           set self::inputFile to inputFile
           invoke self::initProcedurePointers
           goback.
       end method.
       
       method-id initProcedurePointers private.
       01 fileStatus                   string.
      *>   set up procedure pointers for indirect calls. 
           call "AccountStorageAccess"
           set openAccountFile to entry OPEN-ACCOUNT-FILE
           set openCustomerFile to entry OPEN-CUSTOMER-FILE
           set openTransactionFile to entry OPEN-TRANSACTION-FILE
       end method. 

      */
      * Deletes all data. Creates new tables if using OESQL version.
      */
       method-id initializeTables public. 
       copy "FUNCTION-CODES.cpy".
       01 file-status.
               03 status-byte-1                pic x.
               03 status-byte-2                pic x.
      
           call DELETE-ALL-DATA using by reference file-status 
      *    invoke openFile(type FileType::customer, OPEN-WRITE, "00") 
           call INITIALIZE-DATA-SYSTEM using by reference file-status
           if file-status <> "00" then
               raise new Exception("Could not initialize database tables") 
           end-if
           
       end method. 
       
       method-id openFile(filetype as type FileType , opcode as string, allowedStatus as string)
                                   returning result as string
                                   protected.
           01 ppointer             procedure-pointer .
           01 file-status.
               03 status-byte-1                pic x.
               03 status-byte-2                pic x. 
           if size of opcode <> 1 then 
               raise new Exception("Opcode should be one character")
           end-if
           if size of allowedStatus <> 2 then  
               raise new Exception("FileStatus should be two characters")
           end-if
           evaluate filetype
               when type FileType::account
                   set ppointer to openAccountFile 
               when type FileType::customer
                   set ppointer to openCustomerFile
               when type FileType::transaction
                   set ppointer to openTransactionFile
               when other
                   raise new Exception("filetype not matched.")
           end-evaluate
           call ppointer using by value opcode 
                           by reference file-status 
           if file-status <> "00" and file-status <> allowedStatus
               declare printableStatus as string
               if file-status[0] = "9"
                   declare byte2 as binary-char = file-status[1] 
                   set printableStatus to "9" & byte2
               else
                   set printableStatus to file-status
               end-if
               raise new Exception("Returned status " & file-status & " for operation " & opcode)
           end-if
           set result to file-status
       end method. 
       
       method-id createRecords() returning result as condition-value abstract protected.
       end method. 

       method-id stringToInt(#value as string) returning result as binary-long static.
           set result to type Integer::parseInt(#value)
       end method.
       
       method-id stringToDecimal (decString as string) returning result as decimal static. 
           set result to new java.math.BigDecimal(decString) as decimal
       end method. 

       end class.
