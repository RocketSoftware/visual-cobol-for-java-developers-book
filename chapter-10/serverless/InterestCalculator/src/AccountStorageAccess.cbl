      $set ilusing(java.util) 
       program-id. ACCOUNT-STORAGE-ACCESS.
      
       data division.
       working-storage section.
       copy "PROCEDURE-NAMES.cpy".
       01 transaction-index          binary-long. 
       01 transaction-list           type List[binary-char occurs any].

       linkage section. 
       01 LNK-STATUS.
        03 LNK-FILE-STATUS-1         PIC X.
        03 LNK-FILE-STATUS-2         PIC X.
       01 LNK-TRANSACTION-LIST       type List[binary-char occurs any].
       copy "FUNCTION-CODES.cpy".  
       copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by ==LNK==. 
       
       procedure division.
           goback.
       
       ENTRY OPEN-TRANSACTION-FILE using by VALUE LNK-FUNCTION
                                     by reference LNK-STATUS
           move "00" to LNK-STATUS 
           goback.

       ENTRY SET-TRANSACTION-DATA using by value lnk-transaction-list.   
           move LNK-TRANSACTION-LIST to transaction-list    
           goback.

       ENTRY FIND-TRANSACTION-BY-ACCOUNT using by value LNK-FUNCTION
                                 by reference LNK-TRANSACTION-RECORD 
                                                        LNK-STATUS
           evaluate LNK-FUNCTION
               when START-READ
                   if transaction-list = null or transaction-list::size = 0
                       move "23" to LNK-STATUS *> No records
                   else
                       move 0 to transaction-index
                       move "00" to LNK-STATUS                                                  
                   end-if
               when READ-NEXT
                    move "00" to LNK-STATUS
                    if transaction-index < transaction-list::size 
                       declare next-record = 
                               transaction-list::get(transaction-index)
                       set LNK-TRANSACTION-RECORD to next-record
                       add 1 to transaction-index
                       if transaction-index < transaction-list::size 
                           move "02" to LNK-STATUS *> more records
                       end-if
                    end-if
           end-evaluate
           goback. 
       		   	       
           
           

             
