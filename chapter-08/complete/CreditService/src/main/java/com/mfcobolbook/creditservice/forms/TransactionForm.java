/***********************************************************************
 *                                                                     *
 * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.        *
 * All Rights Reserved.                                                *
 *                                                                     *
 ***********************************************************************/

 
package com.mfcobolbook.creditservice.forms;

import java.math.BigDecimal;

import com.mfcobolbook.businessinterop.TransactionDto;

public class TransactionForm {
    private int id;
    private int accountId;
    private String transDate;
    private BigDecimal amount;
    private String description;

    public TransactionForm() {
    }

    public TransactionForm(TransactionDto dto) {
        id = dto.getTransactionId();
        accountId = dto.getAccountId();
        transDate = dto.getDateAsString();
        amount = dto.getAmount();
        description = dto.getDescription().trim();
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public String getTransDate() {
        return transDate;
    }

    public void setTransDate(String transdate) {
        this.transDate = transdate;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public TransactionDto createTransactionDto() {
        return new TransactionDto(id, accountId,
                TransactionDto.convertToLocalDate(transDate), amount,
                description);
    }
}
