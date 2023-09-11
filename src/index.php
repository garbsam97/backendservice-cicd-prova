<?php
	
	try {
		$con = new PDO('mysql:host=dev-db-svc;dbname=prova', 'root', 'wFTJzgYezjGCmfM');
		
		$con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		echo "Connected succesfully";
	} catch (PDOException $e) {
		echo "Connection failed: " . $e->getMessage();
	}
	