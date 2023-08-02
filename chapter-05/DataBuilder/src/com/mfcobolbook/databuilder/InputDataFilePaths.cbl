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
      
      $set ilusing (java.io) 
       class-id com.mfcobolbook.databuilder.InputDataFilePaths public.

       working-storage section.
       01 transactionDataPath      String property with no set. 
       01 customerDataPath         String property with no set.

       method-id new (folderName as string).
           declare folder = new File(folderName)
           if (folder::exists() and folder::isDirectory())
               perform varying nextFile as type File through folder::listFiles()
                   if nextFile::isFile() and nextFile::getName()::endsWith(".csv")
                       if nextFile::getName()::contains("customer")
                           set customerDataPath to nextFile::getAbsolutePath() 
                       else if nextFile::getName()::contains("transaction")
                           set transactionDataPath to nextFile::getAbsoluteFile()
                       end-if
                       if transactionDataPath <> null and customerDataPath <> null
                           goback
                       end-if
                   end-if
               end-perform
           end-if
           raise new DataBuilderException(folderName & " is not a valid directory path")
       end method.
       
       end class.
