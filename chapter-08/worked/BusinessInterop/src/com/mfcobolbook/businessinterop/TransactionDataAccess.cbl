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
      
       class-id com.mfcobolbook.businessinterop.TransactionDataAccess public
           inherits type com.mfcobolbook.businessinterop.AbstractBusinessAccess.

       copy "FUNCTION-CODES.cpy".
       copy "PROCEDURE-NAMES.cpy".


       method-id getTransaction (transactionId as binary-long) returning result as type TransactionDto.
           perform varying result through getTransaction(transactionId, false)
               goback
           end-perform
       end method.

       method-id deleteTransaction (transactionId as binary-long) returning success as condition-value.
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by LS.
       01 fileStatus.
         03 statusByte1 pic x.
         03 statusByte1 pic x.
           move transactionId to LS-TRANSACTION-ID
           call DELETE-TRANSACTION-RECORD USING by reference LS-TRANSACTION-RECORD
                                                             fileStatus
           set success to (fileStatus = "00" )
       end method.

       method-id addTransaction (transaction as type TransactionDto) returning TransactionId as binary-long.
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by LS.
       01 functionCode pic x.
       01 fileStatus.
         03 statusByte1 pic x.
         03 statusByte1 pic x.
           declare nextId as binary-long
           declare lastTransaction = self::getLastTransaction()
           if lastTransaction = null
               set nextId = 1
           else
               set nextId = lasttransaction::transactionId + 1
           end-if
           move WRITE-RECORD to functioncode
           invoke transaction::getAsTransactionRecord(LS-TRANSACTION-RECORD)
           move nextId to LS-transaction-ID
           call WRITE-TRANSACTION-RECORD using by value functionCode
                                               by reference LS-TRANSACTION-RECORD
                                                            fileStatus
           if fileStatus <> "00" and fileStatus <> "02"
               raise new RecordWriteException("Couldn't add new customer record")
           end-if
           set transactionId to nextId
       end method.

       iterator-id getTransaction (transactionId as binary-long, getall as condition-value) yielding result as type TransactionDto.
       01 done condition-value.
       01 fileStarted condition-value.
       01 opcode string.
       01 fileStatus string.

           perform until done
               if not fileStarted
                   move START-READ to opcode
                   invoke readFileByTransactionId(transactionId, opcode, getAll, by reference result)
                   set fileStarted to true
               end-if
               move READ-NEXT to opcode
               set fileStatus to readFileByTransactionId(transactionId, opcode, getAll, by reference result)
               if result = null
                   stop iterator
               else
                   if fileStatus = "00" and getall = false
                       set done to true
                   end-if
                   goback
               end-if
           end-perform
       end iterator.


       method-id updateTransaction (transaction as type TransactionDto)
                               returning success as condition-value.
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by LS.
       01 functionCode pic x.
       01 fileStatus.
         03 statusByte1 pic x.
         03 statusByte1 pic x.
           move UPDATE-RECORD to functioncode
           invoke transaction::getAsTransactionRecord(LS-TRANSACTION-RECORD)
           call WRITE-TRANSACTION-RECORD using by value functionCode
                                               by reference LS-TRANSACTION-RECORD
                                                            fileStatus
           if fileStatus <> "00" and 
              fileStatus <> "02" and
              fileStatus <> "23"  
                   raise new RecordWriteException(
                       "Couldn't update transaction record")
           end-if
           set success to fileStatus <> "23"
       end method.

       iterator-id getTransactionsByAccount (accountId as binary-long) yielding result as type TransactionDto.
           perform varying result through getTransactionsByAccount(accountId, true)
               goback
           end-perform

       end iterator.

       iterator-id getTransactionsByAccount (accountId as binary-long, getall as condition-value) yielding result as type TransactionDto.
       01 done condition-value.
       01 fileStarted condition-value.
       01 opcode string.
       01 fileStatus string.
       01 nextId binary-long.

           perform until done
               if not fileStarted
                   move START-READ to opcode
                   invoke readFileByAccountId(accountId, opcode, by reference result)
                   set fileStarted to true
               end-if
               move READ-NEXT to opcode
               set fileStatus to readFileByAccountId(accountId, opcode, by reference result)
               if result = null or result::accountId <> accountId
                   stop iterator
               else
                   if fileStatus = "00" and getall = false
                       set done to true
                   end-if
                   goback
               end-if
               add 1 to nextId
           end-perform

       end iterator.

       method-id readFileByAccountId (#id as binary-long, opcode as string, by reference dto as type TransactionDto) returning result as string protected.
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by LS.
       01 fileStatus.
         03 statusByte1 pic x.
         03 statusByte1 pic x.
           move #id to LS-ACCOUNT-ID
           call FIND-TRANSACTION-BY-ACCOUNT using by value opCode
                                                  by reference LS-TRANSACTION-RECORD
                                                               fileStatus
           set result to fileStatus
           if fileStatus = "23" or fileStatus = "10"
               set dto to null
           else
               if opCode = READ-NEXT and (fileStatus = "00" or fileStatus = "02")
                   declare localDate = type TransactionDto::convertToLocalDate(LS-TRANS-DATE)
                   set dto to new TransactionDto(LS-TRANSACTION-ID, LS-ACCOUNT-ID,
                     localDate, LS-AMOUNT, LS-DESCRIPTION)
               end-if
           end-if
       end method.
       method-id openEntryPointer override.
       linkage section.
       01 pPointer procedure-pointer.
       procedure divison using by reference pPointer.
           set pPointer to entry OPEN-TRANSACTION-FILE
       end method.

       method-id readFileByTransactionId (#id as binary-long, opcode as string, getAll as condition-value, by reference dto as type TransactionDto) returning result as string protected.

       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by LS.
       01 fileStatus.
         03 statusByte1 pic x.
         03 statusByte1 pic x.
           move #id to LS-TRANSACTION-ID
           call READ-TRANSACTION-RECORD using by value opCode
                                              by reference LS-TRANSACTION-RECORD
                                                           fileStatus
           set result to fileStatus
           if fileStatus = "23" or fileStatus = "10" or 
              fileStatus = "46" or (LS-TRANSACTION-ID <> #id 
                                    and not getAll)
               set dto to null
           else
               if (fileStatus = "00" or fileStatus = "02")
                 and opCode <> START-READ
                   set dto to new TransactionDto(LS-TRANSACTION-ID,
                     LS-ACCOUNT-ID,
                     type TransactionDto::convertToLocalDate(LS-TRANS-DATE)
                     LS-AMOUNT, LS-DESCRIPTION)
               end-if
           end-if

       end method.

       method-id getLastTransaction () returning result as type TransactionDto.
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by LS.
       01 fileStatus.
         03 statusByte1 pic x.
         03 statusByte1 pic x.
           call READ-LAST-TRANSACTION-RECORD using by reference LS-TRANSACTION-RECORD
                                                                fileStatus
           evaluate fileStatus
               when "00"
                   set result to new TransactionDto(LS-TRANSACTION-ID, LS-ACCOUNT-ID,
                     type TransactionDto::convertToLocalDate(LS-TRANS-DATE),
                     LS-AMOUNT, LS-DESCRIPTION)
               when "46"
                   set result to null
               when other
                   declare fs as string
                   set fs to fileStatus
                   raise new FileReadException(fs)
           end-evaluate

       end method.

       end class.
