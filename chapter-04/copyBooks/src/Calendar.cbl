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
      
       program-id. Calendar.

       working-storage section.
       copy "DATE.cpy" replacing ==(PREFIX)== by ==WS==. 
       78 GET-DAYS-IN-MONTH            value "GET-DAYS-IN-MONTH".
       
       01 MOD-RESULT                   pic 99 comp-5. 
       linkage section. 
       copy "DATE.cpy" replacing ==(PREFIX)== by ==LNK==. 
       01 LNK-RESULT                   pic 99 comp-5. 

       procedure division.
           move "20190704" to WS-DATE
           call "GET-DAYS-IN-MONTH" using WS-DATE MOD-RESULT 
           display MOD-RESULT 
           goback.

       ENTRY GET-DAYS-IN-MONTH using by reference LNK-DATE LNK-RESULT. 
           evaluate LNK-MONTH
               when 1
               when 3
               when 5
               when 7
               when 8
               when 10
               when 12
                   move 31 to LNK-RESULT 
               when 2 
                   compute mod-result = function mod (LNK-YEAR, 4)
                   if mod-result = 0 
                       compute mod-result = function mod(LNK-YEAR, 100)
                       if (mod-result = 0)
                           compute mod-result = function mod(LNK-YEAR, 400)
                           if mod-result = 0
                               move 29 to LNK-RESULT
                           else
                               move 28 to LNK-RESULT
                           end-if
                       else
                           move 29 to LNK-RESULT
                       end-if
                   else
                       move 28 to LNK-RESULT
                   end-if
               when other
                   move 30 to LNK-RESULT 
           end-evaluate
           goback.

       end program Calendar.
