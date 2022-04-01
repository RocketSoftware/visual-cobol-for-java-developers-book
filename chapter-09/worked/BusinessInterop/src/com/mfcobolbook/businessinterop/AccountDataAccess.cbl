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
      
       class-id com.mfcobolbook.businessinterop.AccountDataAccess
           inherits AbstractBusinessAccess public.

       working-storage section.
       copy "PROCEDURE-NAMES.cpy".
       copy "FUNCTION-CODES.cpy".

       method-id openEntryPointer override protected.
       linkage section.
       01 pPointer procedure-pointer.
       procedure divison using by reference pPointer.
           set pPointer to entry OPEN-ACCOUNT-FILE
       end method.

       method-id addAccount (account as type AccountDto) 
                   returning accountId as binary-long.
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by LS.

       01 functionCode pic x.
       01 fileStatus.
         03 statusByte1 pic x.
         03 statusByte1 pic x.

           declare nextId as binary-long
           declare lastAccount = self::getLastAccount()
           if lastAccount = null
               set nextId = 1
           else
               set nextId = lastAccount::accountId + 1
           end-if
           move WRITE-RECORD to functioncode
           invoke account::getAsAccountRecord(LS-ACCOUNT)
           move nextId to LS-ACCOUNT-ID
           call WRITE-ACCOUNT-RECORD using by value functionCode
                                           by reference LS-ACCOUNT
                                                        fileStatus
           if fileStatus <> "00" and fileStatus <> "02"
               raise new RecordWriteException(
                       "Couldn't add new account record")
           end-if
           set accountId to nextId
       end method.

       method-id updateAccount (account as type AccountDto)
                       returning success as condition-value. 
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by LS.
       01 functionCode pic x.
       01 fileStatus.
         03 statusByte1 pic x.
         03 statusByte1 pic x.

           move UPDATE-RECORD to functioncode
           invoke account::getAsAccountRecord(LS-ACCOUNT)
           call WRITE-ACCOUNT-RECORD using by value functionCode
                                           by reference LS-ACCOUNT
                                                        fileStatus
           if fileStatus <> "00" and 
              fileStatus <> "02" and 
              fileStatus <> "23"
               raise new RecordWriteException(
                       "Couldn't update record")
           end-if
           set success to fileStatus <> "23" 
       end method.

       method-id deleteAccount (accountId as binary-long) 
                      returning success as condition-value.
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by LS.
       01 fileStatus.
         03 statusByte1 pic x.
         03 statusByte1 pic x.
           move accountId to LS-account-ID
           call DELETE-ACCOUNT-RECORD USING by reference LS-ACCOUNT
                                                         fileStatus
           set success to (fileStatus = "00")
       end method.

       method-id getAccount (accountId as binary-long) 
                             returning result as type AccountDto.
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by LS.
       01 functionCode         pic x. 
       01 fileStatus.
         03 statusByte1 pic x.
         03 statusByte1 pic x.
           move accountId to LS-ACCOUNT-ID 
           call FIND-ACCOUNT-ID using by value functionCode 
                                      by reference LS-ACCOUNT
                                                   fileStatus 
           if fileStatus <> "00" 
               set result to null
           else
               declare accType as binary-char = LS-TYPE
               set result to new AccountDto(LS-ACCOUNT-ID, 
                                                LS-CUSTOMER-ID
                                                LS-BALANCE, 
                                                accType, 
                                                LS-CREDIT-LIMIT)
           end-if
       end method.

       iterator-id getAccounts () yielding result as type AccountDto.
           perform varying result through getAccount(1, true)
               goback
           end-perform
       end iterator.

       iterator-id getAccount (accountId as binary-long, 
                               getall as condition-value) 
                      yielding result as type AccountDto
                      protected.
       01 done condition-value.
       01 fileStarted condition-value.
       01 opcode string.
       01 fileStatus string.

           perform until done
               if not fileStarted
                   move START-READ to opcode
                   invoke readFileById(accountId, opcode, getAll, 
                                       by reference result)
                   set fileStarted to true
               end-if
               move READ-NEXT to opcode
               set fileStatus to readFileById(accountId, opcode, getAll, 
                                              by reference result)
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

       method-id readFileById (#id as binary-long, opcode as string, 
                               getAll as condition-value, 
                               by reference dto as type AccountDto) 
                     returning result as string protected.  
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by LS.
       01 fileStatus.
         03 statusByte1 pic x.
         03 statusByte1 pic x.
       01 accountType binary-char.
           move #id to LS-ACCOUNT-ID
           call READ-ACCOUNT-RECORD using by value opCode
                                          by reference LS-ACCOUNT
                                                       fileStatus
           set result to fileStatus
           if fileStatus = "23" or fileStatus = "10" or  fileStatus="46" or
             (LS-ACCOUNT-ID <> #id and not getAll)
               set dto to null
           else
               if fileStatus = "00" or fileStatus = "02"
                   move LS-TYPE to accountType
                   set dto to new AccountDto(LS-ACCOUNT-ID, LS-CUSTOMER-ID,
                     LS-BALANCE, accountType,
                     LS-CREDIT-LIMIT)
                else 
                       raise new FileReadException("Could not read file " 
                                     &  super::statusToString(fileStatus))
               end-if
           end-if

       end method.

       method-id getLastAccount () returning result as type AccountDto 
                                   protected.
       copy "ACCOUNT-RECORD.cpy" replacing ==(PREFIX)== by LS.
       01 fileStatus.
         03 statusByte1 pic x.
         03 statusByte1 pic x.
           call READ-LAST-ACCOUNT-RECORD using by reference LS-ACCOUNT
                                                            fileStatus
           evaluate fileStatus
               when "00"
                   declare accType as binary-char = LS-TYPE
                   set result to new AccountDto(LS-ACCOUNT-ID, 
                                                LS-CUSTOMER-ID
                                                LS-BALANCE, 
                                                accType, 
                                                LS-CREDIT-LIMIT)
               when "23"
                   set result to null 
               when "46"
                   set result to null
               when other
                   declare fs as string
                   set fs to fileStatus
                   raise new FileReadException(fs)
           end-evaluate

       end method.

       end class.
