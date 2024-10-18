      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
       class-id com.mfcobolbook.examples.RaiseClass public.
       
       method-id Main (args as string occurs any) static public. 
           try
               raise new Exception()
           catch e as type Exception
      *>       Log the exception
               display e::getMessage() 
      *>       Rethrow this exception 
               raise
           finally
               display "We always execute this" 
           end-try
       end method. 
       
       end class.
