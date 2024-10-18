/***********************************************************************
 *                                                                     *
 * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.        *
 * All Rights Reserved.                                                *
 *                                                                     *
 ***********************************************************************/

 

package com.mfcobolbook.creditservice.webservice;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.NOT_FOUND)
public class ResourceNotFoundException extends Exception
{
	private static final long serialVersionUID = 5765016034317629769L;
	
	public ResourceNotFoundException(String message)
	{
		super(message); 
	}

}
