       class-id com.mfcobolbook.businessinterop.AbstractBusinessAccess 
                public abstract implements type AutoCloseable.
       copy "PROCEDURE-NAMES.cpy". 
       copy "FUNCTION-CODES.cpy". 
       01 fileOpened           condition-value. 

       method-id open(openMode as type AbstractBusinessAccess+OpenMode).
           call "ACCOUNT-STORAGE-ACCESS" 
           declare opcode as string
           declare allowedStatus = "00"
           evaluate openMode
               when type AbstractBusinessAccess+OpenMode::read
                   move OPEN-READ to opcode
               when type AbstractBusinessAccess+OpenMode::write
                   move OPEN-WRITE to opcode
                   move "05" to allowedStatus
               when type AbstractBusinessAccess+OpenMode::rw
                   move OPEN-I-O to opcode
           end-evaluate
           invoke openFile(opcode, allowedStatus)
           set fileOpened to true
       end method. 
       
       method-id openFile(opcode as string, allowedStatus as string)
                                   returning result as string protected.
       copy "FUNCTION-CODES.cpy". 
       01 pPointer                         procedure-pointer.
       01 fileStatus.
           03 statusByte1                pic x.
           03 statusbyte2                pic x. 
           
       
           if size of opcode <> 1 then
               raise new Exception("Opcode should be one character")
           end-if
           if size of allowedStatus <> 2 then 
               raise new Exception("FileStatus should be two characters")
           end-if
           
           invoke openEntryPointer(by reference pPointer)   
           call pPointer using by value opcode 
                           by reference fileStatus
       
           if fileStatus <> "00" and fileStatus <> allowedStatus
               raise new FileErrorException("Unexpected file status " 
                                   & statusToString(fileStatus))
           end-if
           set result to fileStatus
       
       end method.
       
       method-id openEntryPointer abstract protected.
       linkage section. 
       01 pPointer                 procedure-pointer.
       procedure divison using by reference pPointer.
       end method.  

       method-id close(). 
           if fileOpened
               invoke openFile(CLOSE-FILE, "00")
               set fileOpened to false
           end-if
       end method.
       
       method-id statusToString(statusCode as string) 
                 returning result as string static public.
       01 displayable          pic 999. 
           if size of statusCode <> 2
               raise new Exception("Status codes must be two characters")
           end-if
           if statusCode[0] <> "9"
               set result to statusCode
           else
               move statusCode[1] to displayable   
               set result to statusCode[0] & displayable
           end-if
       end method. 
       
       enum-id OpenMode.
       78 #read.
       78 #write.
       78 #rw.  
       end enum. 

       
       end class.
