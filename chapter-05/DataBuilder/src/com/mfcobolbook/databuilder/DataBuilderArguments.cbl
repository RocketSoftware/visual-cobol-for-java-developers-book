      ******************************************************************
      *                                                                *
      * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.   *
      * All Rights Reserved.                                           *
      *                                                                *
      ******************************************************************

      
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
       
