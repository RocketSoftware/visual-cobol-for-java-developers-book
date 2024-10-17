      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
      $set ilusing(java.io)
      $set ilusing(java.util) 
       class-id com.mfcobolbook.database.CsvReader public
                implements type AutoCloseable.
       
       01 reader                       type BufferedReader.
       01 endOfDataFlag                condition-value.
       01 nextFields                   string occurs any. 
       
       method-id new (filename as string).
           declare filereader = new FileReader(filename) 
           set reader = new BufferedReader(filereader)
       end method. 
       
       method-id new (stream as type InputStream).
           declare sr = new InputStreamReader(stream)
           set reader = new BufferedReader(sr)
       end method. 
       
       method-id close().
           if reader <> null
               invoke reader::close()
           end-if
       end method. 
       
       iterator-id getRows() yielding result as string occurs any.
           perform until false      
               declare nextLine = reader::readLine()
               if nextLine = null
                   stop iterator
               end-if
               set result to nextLine::split(",")
               goback 
           end-perform
       end iterator. 
           
       end class.
