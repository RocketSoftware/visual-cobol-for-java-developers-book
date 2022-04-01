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
      
       class-id com.mfcobolbook.databuilder.DataBuilderArguments public.
       
       01 operation        type Operation property with no set. 
       01 dateString       String property with no set. 
       01 dataPaths        type InputDataFilePaths property with no set. 
       
       method-id new (args as string occurs any). 
           if (size of args < 3)
               raise new DataBuilderException("Insufficient arguments"); 
           end-if
           evaluate args[0] 
               when "-new"
                   set operation to type Operation::initializeData
               when "-add"
                   set operation to type Operation::addData
               when other
                   raise new DataBuilderException("Invalid first argument")
           end-evaluate
           set dataPaths to new InputDataFilePaths(args[1])
           set dateString to args[2] 
       end method.
       
       
       
       enum-id Operation.
           78 initializeData. 
           78 addData. 
       end enum. 
       end class.
       
