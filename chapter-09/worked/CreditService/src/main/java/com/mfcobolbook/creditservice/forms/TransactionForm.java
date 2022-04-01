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
