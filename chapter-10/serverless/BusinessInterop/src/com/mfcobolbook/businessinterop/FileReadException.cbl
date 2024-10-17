      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
       class-id com.mfcobolbook.businessinterop.FileReadException public
           inherits type java.lang.Exception.

       method-id new (fileStatus as string).
           invoke super::new("File status is " & fileStatus) 
       end method. 
       
       end class.
       
