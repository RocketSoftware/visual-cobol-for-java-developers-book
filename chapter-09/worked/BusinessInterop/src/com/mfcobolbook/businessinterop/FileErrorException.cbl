      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
       class-id com.mfcobolbook.businessinterop.FileErrorException public
                   inherits type java.lang.RuntimeException.

       working-storage section.

       method-id new (msg as string).
           invoke super::new(msg)

           goback.
       end method.
       
       end class.
