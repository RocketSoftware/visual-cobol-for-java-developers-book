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
 
package com.mfcobolbook.lambda;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.amazonaws.services.lambda.runtime.Context;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.mfcobolbook.businessinterop.StatementDto;

/**
 * A simple test harness for locally invoking your Lambda function handler.
 */
//@RunWith(MockitoJUnitRunner.class)
public class ProxyWithStreamTest 
{
	  private static BigDecimal DAILY_RATE = new BigDecimal(0.1)
	          .divide(new BigDecimal(365), 10, RoundingMode.HALF_UP);
	  private static String[][] TEST_DATA = new String[][] {
	      {"256","20","20190703","62.70000", "Books"},
	      {"257", "20", "20190708", "7.430000", "Jewelery"},
	      {"258", "20", "20190714", "20.80000", "Automotive"},
	      {"259", "20", "20190717", "7.970000", "Games"},
	      {"260", "20", "20190717", "64.27000", "Baby"},
	      {"261", "20", "20190726", "85.90000", "Shoes"},
	      {"262", "20", "20190731", "94.97000", "Grocery"}
	          };
    
  
	private Context context ; 
	
    @BeforeEach
    public void setUp() throws IOException 
    {
    	context = createContext(); 
    }

    private Context createContext() 
    {
        TestContext ctx = new TestContext();
        ctx.setFunctionName("CreditService");
        return ctx;
    }
    
    @Test
    public void invokeStreamHandlerTest() throws IOException { 
       Gson gson = new GsonBuilder().setPrettyPrinting().create();
       CalculationRequest request = new CalculationRequest(); 
       LocalDate startDate = LocalDate.of(2019, 7, 1);
       request.setDayRate(DAILY_RATE);
       request.setStartingAmount(new BigDecimal(100));
       request.setStartDate(startDate);
       request.setTransactions(TEST_DATA);
       String json = gson.toJson(request) ;
       InputStream input = new ByteArrayInputStream(json.getBytes());  
       ByteArrayOutputStream output = new ByteArrayOutputStream() ; 
       InterestCalculatorFunction handler = new InterestCalculatorFunction() ; 
       handler.handleRequest(input, output, context);
       validateResults(output);
    }
    
    @Test
    public void gatewayTest() throws IOException { 
       InputStream input = ProxyWithStreamTest.class.getClassLoader().getResourceAsStream("gateway-stream.json") ; 
       ByteArrayOutputStream output = new ByteArrayOutputStream() ; 
       InterestCalculatorFunction handler = new InterestCalculatorFunction() ; 
       handler.handleApiRequest(input, output, context);
       validateResults(output); 

    }
    
    
    private void validateResults(ByteArrayOutputStream output) {
        Gson gson = new Gson(); 
        String result = output.toString(); 
        StatementDto statement = gson.fromJson(result, StatementDto.class) ;
        assertNotNull(statement);
        assertEquals(new BigDecimal("445.87"), statement.getEndingAmount()) ;
        assertEquals(new BigDecimal("1.96"), statement.getInterestAmount()) ;

    }



}
