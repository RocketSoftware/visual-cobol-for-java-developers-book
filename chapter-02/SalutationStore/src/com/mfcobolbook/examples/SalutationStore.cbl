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
      
       class-id com.mfcobolbook.examples.SalutationStore public.

       01 greetingsDictionary          dictionary[string, string]. 
       
       method-id new.
           invoke initData() 
       end method. 
       
       method-id initData.
           create greetingsDictionary 
           write greetingsDictionary from "Hello World" key "english"
           write greetingsDictionary from "Bonjour le monde" key "french"
           write greetingsDictionary from "Hallo Welt" key "german"
       end method.
       
       method-id fetchGreeting(language as string) returning result as string.
           set language to language::toLowerCase()
           read greetingsDictionary into result key language
               invalid key
                   set result to "I don't speak this language" 
                   
                   
           end-read 
       end method. 
       
       end class.
