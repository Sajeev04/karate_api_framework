package utils;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.URL;

public class BCDBDbUpdate {

public static boolean updateKvkInDb(String kvk, String environment) throws Exception {
	boolean updateStatus = false;
	String dataSetupUrl = "http://vm00006321:48134/KVKCheck";
	if(environment.equalsIgnoreCase("ET")) {
		dataSetupUrl = dataSetupUrl.concat("?Env=ET1").concat("&KVKNumber=").concat(kvk).concat("&RemoveL4=true&ClearAMXFlag=true&RemoveL2=true");
	}else {
		dataSetupUrl = dataSetupUrl.concat("?Env=ST").concat("&KVKNumber=").concat(kvk).concat("&RemoveL4=true&ClearAMXFlag=true&RemoveL2=true");
	}
		doGET(dataSetupUrl, false);
		return updateStatus;
	}

public  static String doGET(String urls,boolean isProxy ) {
	String output = "";
	  try {
		  System.out.println("do Get and url is " + urls);
			URL url = new URL(urls);
			Proxy proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress("nl-userproxy-access.net.abnamro.com", 8080));
			HttpURLConnection conn = null;
			if(isProxy) {
				 conn = (HttpURLConnection) url.openConnection(proxy);
			}else {
				conn = (HttpURLConnection) url.openConnection();
			}
			conn.setConnectTimeout(33000);
			conn.setRequestMethod("GET");
			conn.setRequestProperty("Accept", "application/json");
			System.out.println(conn.getResponseCode());
			BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));
			String line ;
			while ((line = br.readLine()) != null) {
				output+=line;
			}
			System.out.println(output);
			conn.disconnect();
		  } catch (Exception e) {
			e.printStackTrace();
		  }
	  return output;
}
}

