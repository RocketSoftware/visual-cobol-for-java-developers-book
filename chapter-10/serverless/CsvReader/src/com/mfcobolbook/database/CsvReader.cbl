      *****************************************************************
      *                                                               *
      * Copyright (C) 2020-2022 Micro Focus.  All Rights Reserved.    *
      * This software may be used, modified, and distributed          *
      * (provided this notice is included without modification)       *
      * solely for demonstration purposes with other                  *
      * Micro Focus software, and is otherwise subject to the EULA at *
      * https://www.microfocus.com/en-us/legal/software-licensing.    *
      *                                                               *
      * THIS SOFTWARE IS PROVIDED "AS IS" AND ALL IMPLIED           *
      * WARRANTIES, INCLUDING THE IMPLIED WARRANTIES OF               *
      * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE,         *
      * SHALL NOT APPLY.                                              *
      * TO THE EXTENT PERMITTED BY LAW, IN NO EVENT WILL              *
      * MICRO FOCUS HAVE ANY LIABILITY WHATSOEVER IN CONNECTION       *
      * WITH THIS SOFTWARE.                                           *
      *                                                               *
      *****************************************************************
      
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
