      *****************************************************************
      *                                                               *
      * Copyright 2020-2023 Open Text. All Rights Reserved.           *
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
