      $set ilusing(java.io)
      $set ilusing(java.util) 
       class-id com.mfcobolbook.databuilder.TextFieldParser public
                implements type AutoCloseable. 
       
       01 reader                       type BufferedReader.
       01 endOfDataFlag                condition-value.
       01 nextFields                   string occurs any. 
       
       method-id new (filename as string).
           declare filereader = new FileReader(filename) 
           set reader = new BufferedReader(filereader)
           set nextFields to internalNext()
       
       end method. 
       
       method-id close().
           if reader <> null
               invoke reader::close()
           end-if
       end method. 

       method-id endOfData() returning result as condition-value.
           set result to endOfDataFlag 
       end method. 
       
       method-id internalNext() returning nextFields as string occurs any private.
           declare nextLine = reader::readLine()
           if nextLine = null
               set endOfDataFlag to true
               set nextFields to null
           else
               set nextFields to nextLine::split(",") 
           end-if
           
       end method. 
       
       method-id next() returning nextFields as string occurs any.
           set nextFields to self::nextFields
           set self::nextFields to internalNext()
       end method. 
       
       method-id remove. 
       end method. 
       
       end class.
