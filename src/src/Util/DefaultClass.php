<?php
	
	namespace Backendservice\BackendserviceCicd\Util;
	
	class DefaultClass
	{
		private string $greetings = "Hello world";
		
		public function getGreetings(): string
		{
			return $this->greetings;
		}
	}
