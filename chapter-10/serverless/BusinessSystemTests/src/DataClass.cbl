      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
       class-id DataClass public.

       working-storage section.
       method-id GetByteArray returning result as binary-char occurs any static.
           copy "TRANSACTION-RECORD.cpy" replacing ==(PREFIX)== by ==WS==. 
            declare record-bytes  as binary-char occurs any.
           set size of record-bytes to length of WS-TRANSACTION-RECORD     
           set result to record-bytes 
       end method.
       
       end class.
