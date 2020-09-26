       program-id. Calendar. 

       working-storage section.
       copy "PROCEDURE-NAMES.cpy". 
       01 mod-result           pic 99 comp-5. 
       linkage section. 
       copy "DATE.cpy" replacing ==(PREFIX)== by ==LNK==. 
       01 LNK-RESULT                     pic 99 comp-5. 

       procedure division.
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