/****************************************************************************
 *
 *   Copyright (C) Micro Focus IP Development Limited  2012. 
 *   All rights reserved.
 *
 *   The software and information contained herein are proprietary to, and
 *   comprise valuable trade secrets of, Micro Focus IP Development Limited, 
 *   which intends to preserve as trade secrets such software and 
 *   information. This software is an unpublished copyright of Micro Focus  
 *   and may not be used, copied, transmitted, or stored in any manner.  
 *   This software and information or any other copies thereof may not be
 *   provided or otherwise made available to any other person.
 *   
 *   $Id: mf.cloud.codetemplates.xml 485282 2012-04-05 08:06:58Z pk $
 ****************************************************************************/

package com.mfcobolbook.creditservice.webservice;

import java.util.List;

/**
 * Used to ensure JSON Arrays are safely wrapped. 
 * @author Micro Focus
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

