package utils;


public class SMSessionCreator implements Constants{

	public static String employeeSession(String username,String password,String domain,String env){
		try {
			if(env.equals("ET")) {
				return HTTPCalls.HTTPGetEmployeeSession(INTRANET_ET_URL,domain,username, password);
			}else {
				return HTTPCalls.HTTPGetEmployeeSession(INTRANET_ST_URL,domain,username, password);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}
	public static String userSession(String cardnumber,String passnumber,String env) {
		try {
			System.out.println(cardnumber + " " +passnumber);
			if(env.equals("ET")) {
				return HTTPCalls.internetSession(INTERNET_ET_URL,cardnumber, passnumber,false);
			}else {
				return HTTPCalls.internetSession(INTERNET_ST_URL,cardnumber, passnumber,true);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";		
	}
}