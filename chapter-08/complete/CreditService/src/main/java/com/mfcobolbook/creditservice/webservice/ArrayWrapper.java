/***********************************************************************
 *                                                                     *
 * Copyright 2020-2024 Rocket Software, Inc. or its affiliates.        *
 * All Rights Reserved.                                                *
 *                                                                     *
 ***********************************************************************/

 

package com.mfcobolbook.creditservice.webservice;

import java.util.List;

/**
 * Used to ensure JSON Arrays are safely wrapped. 
 * @author Rocket Software
 *
 * @param <T>
 */
public class ArrayWrapper<T>
{
	private List<T> array ;
	
	public ArrayWrapper (List<T> data)
	{
		array = data; 
	}
	
	public List<T> getArray()
	{
		return array;
	}
}

