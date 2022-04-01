set COBDIR=C:\Program Files (x86)\Micro Focus\Visual COBOL
mvn install:install-file -Dfile="%COBDIR%\bin\mfcobolrts.jar" -DgroupId=com.microfocus.cobol.rts -DartifactId=mfcobolrts -Dversion=7.0.0 -Dpackaging=jar
mvn install:install-file -Dfile="%COBDIR%\bin\mfcobol.jar" -DgroupId=com.microfocus.cobol.rts -DartifactId=mfcobol -Dversion=7.0.0 -Dpackaging=jar
mvn install:install-file -Dfile="%COBDIR%\bin\mfsqljvm.jar" -DgroupId=com.microfocus.cobol.rts -DartifactId=mfsqljvm -Dversion=7.0.0 -Dpackaging=jar
