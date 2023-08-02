/*****************************************************************
 *                                                               *
 * Copyright 2020-2023 Open Text. All Rights Reserved.           *
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

import java.io.IOException;
import java.io.InputStream;

import org.springframework.boot.SpringApplication;

import com.mfcobolbook.database.DatabaseInitializerWrapper;

import io.restassured.RestAssured;

public abstract class WebserviceApplicationTests {
    private static boolean hasInitialized = false; 
    
    private DatabaseInitializerWrapper databaseInitializerWrapper ; 
    
    public static void setup() {
        if (!hasInitialized) {
            SpringApplication application = new SpringApplication(WebserviceApplication.class) ;
            RestAssured.port = 8088;
            application.run(new String[] {}); 
            hasInitialized = true; 
        }
    }

    protected void initTestData() throws IOException {
    	databaseInitializerWrapper = new DatabaseInitializerWrapper();
        createEmptyTables(); 
        populateTables(); 
    }

    private void populateTables() throws IOException {
    	InputStream csvStream = getCsvPath("customer.csv");
    	databaseInitializerWrapper.loadCustomerData(csvStream);
    	csvStream = getCsvPath("account.csv");
    	databaseInitializerWrapper.loadAccountData(csvStream);
    	csvStream = getCsvPath("transaction.csv");
    	databaseInitializerWrapper.loadTransactionData(csvStream);
    }
    
    private InputStream getCsvPath(String source) 
            throws IOException {
        return WebserviceApplicationTests.class.getClassLoader()
        		.getResourceAsStream(source);
    }
    
    private void createEmptyTables() {
        databaseInitializerWrapper.dropAndCreateTables();
    }    

}
