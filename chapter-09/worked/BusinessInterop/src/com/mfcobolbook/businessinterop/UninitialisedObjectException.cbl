       class-id com.mfcobolbook.businessinterop.UninitialisedObjectException 
                inherits type java.lang.RuntimeException.

       method-id new (msg as string).
           invoke super::new(msg)
           goback.
       end method.
       
       end class.
