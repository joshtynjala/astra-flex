/*
Copyright (c) 2009 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.net
{
	import flash.utils.ByteArray;
	
	/**
	 * A representation of an IP Address (version 4).
	 * 
	 * @author Josh Tynjala
	 */
	public class IPv4Address
	{
		
	//--------------------------------------
	//  Constructor
	//--------------------------------------
	
		/**
		 * Constructor.
		 * 
		 * @param value		the initial input. May be a string or a 4-byte ByteArray
		 * 
		 * @see flash.utils.ByteArray
		 */
		public function IPv4Address(value:Object = null)
		{
			this.parse(value);
		}
		
	//--------------------------------------
	//  Public Methods
	//--------------------------------------
	
		/**
		 * Converts the internal byte data to a full IPv4 address string.
		 * 
		 * <p>Example: <code>127.0.0.1</code></p>
		 */
		public function toString():String
		{
			return this.value;
		}
		
		/**
		 * Parses a representation of an IPv4 address. May be a string or a 4-byte ByteArray.
		 * 
		 * @see flash.utils.ByteArray
		 */
		public function parse(input:Object):void
		{
			if(input == null)
			{
				this.clear();
				return;
			}
			else if(input is ByteArray)
			{
				var byteInput:ByteArray = ByteArray(input);
				if(byteInput.length == 4)
				{
					this._bytes = new ByteArray();
					this._bytes.writeBytes(byteInput);
				}
				else
				{
					this.clear();
					return;
				}
			}
			else
			{
				//must be a string
				input = input.toString();
				var parsedBytes:ByteArray = new ByteArray();
				var parts:Array = String(input).split(".");
				if(parts.length != 4)
				{
					this.clear();
					return;
				}
				
				for each(var part:String in parts)
				{
					var byte:int = int(part);
					if(isNaN(Number(part)) || byte < 0 || byte > 255)
					{
						this.clear();
						return;
					}
					
					parsedBytes.writeByte(byte);
				}
				this._bytes = parsedBytes; 
			}
		}
		
	//--------------------------------------
	//  Properties
	//--------------------------------------
		
		/**
		 * @private
		 * Storage for the bytes property.
		 */
		private var _bytes:ByteArray;
		
		/**
		 * The raw 4-byte representation of an IPv4 address.
		 */
		public function get bytes():ByteArray
		{
			return this._bytes;
		}
		
		/**
		 * @private
		 */
		public function set bytes(value:ByteArray):void
		{
			if(value.length != 4)
			{
				this.clear();
			}
			this._bytes = value;
		}
		
		/**
		 * The String representation of the IPv4Address.
		 */
		public function get value():String
		{
			return this.bytes[0] + "." + this.bytes[1] + "." + this.bytes[2] + "." + this.bytes[3];
		}
		
		/**
		 * @private
		 */
		public function set value(value:String):void
		{
			this.parse(value);
		}
		
	//--------------------------------------
	//  Private Methods
	//--------------------------------------
		
		/**
		 * @private
		 * Clears the address to value <code>0.0.0.0</code>.
		 */
		private function clear():void
		{
			this._bytes = new ByteArray();
			this._bytes.writeByte(0);
			this._bytes.writeByte(0);
			this._bytes.writeByte(0);
			this._bytes.writeByte(0);
		}
	}
}