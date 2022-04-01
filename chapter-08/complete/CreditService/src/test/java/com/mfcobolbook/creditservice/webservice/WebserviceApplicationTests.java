/*****************************************************************
 *                                                               *
 * Copyright (C) 2020-2022 Micro Focus. All Rights Reserved.     *
 * This software may be used, modified, and distributed          *
 * (provided this notice is included without modification)       *
 * solely for demonstration purposes with other                  *
 * Micro Focus software, and is otherwise subject to the EULA at *
 * https://www.microfocus.com/en-us/legal/software-licensing.    *
 *                                                               *
 * THIS SOFTWARE IS PROVIDED "AS IS" AND ALL IMPLIED             *
 * WARRANTIES, INCLUDING THE IMPLIED WARRANTIES OF               *
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE,         *
 * SHALL NOT APPLY.                                              *
 * TO THE EXTENT PERMITTED BY LAW, IN NO EVENT WILL              *
 * MICRO FOCUS HAVE ANY LIABILITY WHATSOEVER IN CONNECTION       *
 * WITH THIS SOFTWARE.                                           *
 *                                                               *
 *****************************************************************/
 
package com.mfcobolbook.creditservice.webservice;

import static org.junit.Assert.assertNotNull;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

import org.springframework.boot.SpringApplication;

import io.restassured.RestAssured;

public abstract class WebserviceApplicationTests {
    private static boolean hasInitialized = false; 
    
    public static void setup() {
        if (!hasInitialized) {
            SpringApplication application = new SpringApplication(WebserviceApplication.class) ;
            RestAssured.port = 8088;
            application.run(new String[] {}); 
            hasInitialized = true; 
        }
    }

    protected void initTestData() throws IOException {
        copyDataResource("account.testdat", "dd_ACCOUNTFILE");
        copyDataResource("customer.testdat", "dd_CUSTOMERFILE");
        copyDataResource("transaction.testdat", "dd_TRANSACTIONFILE");
    }

    private void copyDataResource(String source, String target)
            throws IOException {
        URL url = WebserviceApplicationTests.class.getClassLoader()
                .getResource(source);
        String path = url.getPath();
        assertNotNull(String.format("No resource found for %s", source),
                path);
        Path sourcePath = new File(path).toPath();
        String environmentValue = System.getenv().get(target);
        assertNotNull(String.format("No value found for %s", target),
                environmentValue);
        assertNotNull(sourcePath);
        File targetFile = new File(environmentValue);
        targetFile.getParentFile().mkdir();
        Files.copy(sourcePath, targetFile.toPath(),
                StandardCopyOption.REPLACE_EXISTING);
    }
}
