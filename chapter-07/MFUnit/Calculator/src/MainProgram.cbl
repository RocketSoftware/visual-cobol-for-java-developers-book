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
      
       program-id. MainProgram.

       data division.
       working-storage section.
       linkage section. 
       01 operand1                 pic s9(15)v9(10).
       01 operand2                 pic s9(15)v9(10).
       01 result                   pic s9(15)v9(10). 
       01 function-code            pic x.
       procedure division.
           goback. 
           
       entry "Calculate" using by reference operand1 operand2 
                                             function-code result. 
           evaluate function-code
           when "M"
               move 102.3 to result
      *        multiply operand1 by operand2 giving result
           when "D"
               divide operand1 by operand2 giving result
           when other
               move -1 to return-code
           end-evaluate
           exit program returning return-code.

