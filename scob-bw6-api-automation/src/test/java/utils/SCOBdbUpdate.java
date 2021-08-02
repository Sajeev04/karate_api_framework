package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class SCOBdbUpdate {
	
	public static boolean insertRecordInMaintenance() {
		boolean status = false;
		String query = "insert into COB_CLM.MAINTENANCE values ('ECM2',CURRENT_TIMESTAMP,(select CURRENT_TIMESTAMP + interval '1' minute from dual))";
		try {
			Class.forName("oracle.jdbc.driver.OracleDriver");
			Connection con = DriverManager.getConnection("jdbc:oracle:thin:@ab3s1d04.nl.eu.abnamro.com:24001:SBPMAC","COB_CLM", "qfssf901");
			Statement stmt = con.createStatement();
			int count = stmt.executeUpdate(query);
			System.out.println(count);
			con.close();
			status = true;
		} catch (ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}finally {
			
		}
		return status;
	}

}
