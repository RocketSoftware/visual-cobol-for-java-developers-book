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
