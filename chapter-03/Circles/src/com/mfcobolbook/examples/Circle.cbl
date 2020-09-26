      *> Class header identifies namespace and class name
       class-id com.mfcobolbook.examples.Circle public.

      *> fields. All are "private" unless marked otherwise
       78 PI                          value 3.1415926.
      *> SHARED-DATA is a constant available inside and outside
      *> thecircle class
       01 SHARED-DATA                 float-short value PI 
                                      static public initialize only. 
      *> Field exposed as a read-only property. The field is private
      *> but the read-only property is public by default. 
       01 radius                    float-short property with no set. 

      *> Constructor. Public where there is no access modifier.  
       method-id new (radius as float-short).
         set self::radius to radius
       end method. 
       
       property-id Circumference float-short.
         getter. 
             set property-value to radius * SHARED-DATA * 2
       end property.
       
       method-id calculateArea() returning result as float-short. 
         set result to radius * radius * SHARED-DATA 
       end method. 

       method-id main(args as string occurs any) static public.
           declare aCircle = new Circle(5)
           display aCircle::Circumference
       end method.

       end class.