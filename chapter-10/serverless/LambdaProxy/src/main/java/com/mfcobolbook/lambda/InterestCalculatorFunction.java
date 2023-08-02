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

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.text.StringEscapeUtils;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.mfcobolbook.businessinterop.MonthlyInterest;
import com.mfcobolbook.businessinterop.StatementDto;
import com.mfcobolbook.businessinterop.TransactionDto;
import com.microfocus.cobol.runtimeservices.generic.RunUnit;

public class InterestCalculatorFunction
        implements RequestStreamHandler {
    private LambdaLogger logger;

    public void handleRequest(InputStream inputStream,
            OutputStream outputStream, Context context)
            throws IOException {
        BufferedWriter writer = new BufferedWriter(
                new OutputStreamWriter(outputStream));
        try {
            logger = context.getLogger();
            logger.log("Starting InterestCalculatorFunction");

            Gson gson = new GsonBuilder().setPrettyPrinting()
                    .create();
            CalculationRequest request = gson.fromJson(
                    new InputStreamReader(inputStream),
                    CalculationRequest.class);
            StatementDto dto = doCalculation(request);
            String json = gson.toJson(dto);
            writer.write(json);
        } catch (Exception e) {
            logger.log(e.getMessage());
        } finally {
            writer.close();
        }
    }

    public void handleApiRequest(InputStream inputStream,
            OutputStream outputStream, Context context)
            throws IOException {
        BufferedWriter writer = new BufferedWriter(
                new OutputStreamWriter(outputStream));
        try {

            LambdaLogger logger = context.getLogger();
            logger.log("handleApiRequest");
            Gson gson = new GsonBuilder().setPrettyPrinting()
                    .create();
            JsonObject o = JsonParser
                    .parseReader(new InputStreamReader(inputStream))
                    .getAsJsonObject();
            JsonElement element = o.get("body");

            if (element == null) {
                logger.log("No body element found");
            } else {
                logger.log(element.toString());
            }

            String unescapedBody = StringEscapeUtils
                    .unescapeJson(element.toString());
            String unwrappedRequest = StringUtils
                    .unwrap(unescapedBody, '"');
            CalculationRequest request = gson.fromJson(
                    unwrappedRequest, CalculationRequest.class);

            if (request == null) {
                logger.log("No calculation request found");
            } else {
                logger.log(request.toString());
            }
            StatementDto dto = doCalculation(request);
            if (dto == null) {
                logger.log("No DTO returned");
            }
            String json = gson.toJson(dto);
            writer.write(json);
        } catch (Exception e) {
            logger.log(e.getMessage());
        } finally {
            writer.close();
        }
    }

    StatementDto doCalculation(CalculationRequest request) {
        List<TransactionDto> transactions = new ArrayList<TransactionDto>();
        for (String[] row : request.getTransactions()) {
            TransactionDto dto = new TransactionDto(
                    Integer.parseInt(row[0]),
                    Integer.parseInt(row[1]),
                    parseDateString(row[2]), new BigDecimal(row[3]),
                    row[4]);
            transactions.add(dto);
        }
        try (RunUnit<MonthlyInterest> ru = new RunUnit<>(
                MonthlyInterest.class)) {
            MonthlyInterest statement = (MonthlyInterest) ru
                    .GetInstance(MonthlyInterest.class, true);
            statement.init(request.getDayRate(),
                    request.getStartingAmount(),
                    request.getStartDate(), request.getAccountId(),
                    transactions);
            return statement.getStatementDto();
        }
    }

    private LocalDate parseDateString(String s) {
        int year = Integer.parseInt(s.substring(0, 4));
        int month = Integer.parseInt(s.substring(4, 6));
        int day = Integer.parseInt(s.substring(6, 8));
        return LocalDate.of(year, month, day);
    }

}
