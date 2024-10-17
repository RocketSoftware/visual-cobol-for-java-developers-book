/***********************************************************************
 *                                                                     *
 * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.        *
 * All Rights Reserved.                                                *
 *                                                                     *
 ***********************************************************************/

 
package com.mfcobolbook.creditservice.forms;

import com.mfcobolbook.businessinterop.CustomerDto;

public class CustomerForm {
	private int id ; 
	private String firstName; 
	private String lastName; 

	public CustomerForm() {}
	
	public CustomerForm(CustomerDto dto)
	{
		id = dto.getCustomerId();
		firstName = dto.getFirstName(); 
		lastName = dto.getLastName() ; 
				
	}
	
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getFirstName() {
		return firstName;
	}
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}
	public String getLastName() {
		return lastName;
	}
	public void setLastName(String secondName) {
		this.lastName = secondName;
	}
	
	public CustomerDto createCustomerDto()
	{
		return new CustomerDto(id, firstName, lastName); 
	}
	
}
