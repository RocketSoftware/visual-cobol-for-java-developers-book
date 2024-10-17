      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
      $set ilusing(com.microfocus.cobol.runtimeservices) 
       class-id com.mfcobolbook.businessinterop.CustomerDataAccess 
                inherits AbstractBusinessAccess public. 
       
       copy "FUNCTION-CODES.cpy".     
       copy "PROCEDURE-NAMES.cpy".

       method-id getCustomer (customerId as binary-long) 
                   returning result as type CustomerDto.
           perform varying result through getCustomer(customerId, false)
               goback
           end-perform
           
       end method. 
       
       method-id deleteCustomer (customerId as binary-long) 
                      returning success as condition-value.
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by LS.
       01 fileStatus.
        03 statusByte1         pic x.
        03 statusByte1         pic x.
           move customerId to LS-CUSTOMER-ID
           call DELETE-CUSTOMER-RECORD USING 
                                   by reference LS-CUSTOMER-RECORD
                                                fileStatus 
           set success to  (fileStatus = "00")
       end method. 
                   
       method-id addCustomer (customer as type CustomerDto) 
                  returning customerId as binary-long. 
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by LS.
       copy "FUNCTION-CODES.cpy". 
       
       01 functionCode         pic x. 
       01 fileStatus.
        03 statusByte1         pic x.
        03 statusByte1         pic x.
           declare nextId as binary-long
           declare lastCustomer = self::getLastCustomer()
           if lastCustomer = null
               set nextId = 1 
           else
               set nextId = lastCustomer::customerId + 1
           end-if
           set customer::customerId to nextId 
           move WRITE-RECORD to functionCode
           invoke customer::getAsCustomerRecord(LS-CUSTOMER-RECORD)
           call WRITE-CUSTOMER-RECORD using by value functionCode
                                        by reference LS-CUSTOMER-RECORD
                                                     fileStatus
           if fileStatus <> "00" and fileStatus <> "02"
               raise new RecordWriteException("Couldn't add new customer record")
           end-if
           set customerId to nextid 
       end method. 
       
       method-id updateCustomer(customer as type CustomerDto)
                      returning success as condition-value.
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by LS.
       copy "FUNCTION-CODES.cpy". 
       01 functionCode         pic x. 
       01 fileStatus.
        03 statusByte1         pic x.
        03 statusByte1         pic x.
           move UPDATE-RECORD to functionCode
           invoke customer::getAsCustomerRecord(LS-CUSTOMER-RECORD)
           call WRITE-CUSTOMER-RECORD using by  value functionCode
                                         by reference LS-CUSTOMER-RECORD
                                                      fileStatus
           if fileStatus <> "00" and 
              fileStatus <> "02" and
              fileStatus <> "23"  
               raise new RecordWriteException(
                       "Couldn't update customer record")
           end-if
           set success to fileStatus <> "23"
       end method. 
       
       iterator-id getCustomers ()
                   yielding result as type CustomerDto.
           perform varying result through getCustomer(1, true)
               goback
           end-perform
           
       end iterator. 
       
       iterator-id getCustomer (customerId as binary-long, getall as condition-value) 
                   yielding result as type CustomerDto.
       01 done                 condition-value. 
       01 fileStarted          condition-value.
       01 opcode               string. 
       01 fileStatus           string. 
       01 nextId               binary-long. 
           
           perform until done 
               if not fileStarted 
                   move START-READ to opcode
                   invoke readFileById(customerId, opcode, by reference result)
                   move customerId to nextId 
                   set fileStarted to true
               end-if
               move READ-NEXT to opcode
               set fileStatus to readFileById(nextId, opcode, by reference result) 
               if result = null 
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
       
       method-id readFileById(#id as binary-long, opcode as string, 
                              by reference dto as type CustomerDto)
                              returning result as string.
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by LS.
       01 fileStatus.
        03 statusByte1         pic x.
        03 statusByte1         pic x.
           move #id to LS-CUSTOMER-ID
           call FIND-CUSTOMER-ID using by value opCode
                                   by reference LS-CUSTOMER-RECORD
                                                fileStatus 
           set result to fileStatus
           if fileStatus = "23" or fileStatus = "10" or fileStatus = "46"
               set dto to null
           else 
               if fileStatus = "00" or fileStatus = "02"
                   set dto to new CustomerDto(LS-CUSTOMER-ID, LS-FIRST-NAME,
                                                 LS-LAST-NAME)
               end-if
           end-if 

       end method. 
       
       method-id getLastCustomer() returning result as type CustomerDto.
       copy "CUSTOMER-RECORD.cpy" replacing ==(PREFIX)== by LS. 
       01 fileStatus.
        03 statusByte1         pic x.
        03 statusByte1         pic x.
       
           call READ-LAST-CUSTOMER-RECORD USING 
                                   by reference LS-CUSTOMER-RECORD
                                                fileStatus
           evaluate fileStatus
           when  "00" 
               set result to new CustomerDto(LS-CUSTOMER-ID, LS-FIRST-NAME,
                                         LS-LAST-NAME)
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
       
       method-id openEntryPointer override protected.
       linkage section. 
       01 pPointer                 procedure-pointer.
       procedure divison using by reference pPointer. 
           set pPointer to entry OPEN-CUSTOMER-FILE
       end method. 
       
       end class.
       
       

