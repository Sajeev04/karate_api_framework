package utils;

import java.io.IOException;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class DigiSign {
	
	public static boolean performDigiSign(String digiSignUrl,String sessionId,String bc, String toolId,String signItemId,String DocId) {
		boolean status = false;
		OkHttpClient client = new OkHttpClient();
		MediaType mediaType = MediaType.parse("text/xml;charset=UTF-8");
		String reqBody = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:gen=\"http://genericsigning.service.channels.nl.abnamro.com/\">\r\n  <soapenv:Header/>\r\n   <soapenv:Body>\r\n      <gen:updateSignItems>\r\n         <gen:SignItemUpdateDTOList>\r\n            <revisionNumber>1</revisionNumber>\r\n            <signItemId>"+signItemId+"</signItemId>\r\n            <signersData>\r\n               <indicationCosigner>true</indicationCosigner>          \r\n               <signatureDocumentId>"+DocId+"</signatureDocumentId>             \r\n               <signer>"+bc+"</signer>\r\n               <signingChannel>1</signingChannel>\r\n             </signersData>          \r\n            <signingResultStatus>FULLY_SIGNED</signingResultStatus>\r\n         </gen:SignItemUpdateDTOList>\r\n         <gen:SigningContextDTO>\r\n            <contactMethod>cmet</contactMethod>\r\n            <contactReference>cref</contactReference>\r\n            <contactType>ctype</contactType>\r\n            <securityContextDTO>\r\n               <bcToolOwner>"+bc+"</bcToolOwner>\r\n               <channel>1</channel>\r\n               <sessionId>"+sessionId+"</sessionId>\r\n               <toolId>"+toolId+"</toolId>\r\n               <toolType>1</toolType>\r\n               <toolUsage>12</toolUsage>\r\n               <userClass>BC</userClass>\r\n               <userReference>"+bc+"</userReference>\r\n            </securityContextDTO>\r\n         </gen:SigningContextDTO>\r\n      </gen:updateSignItems>\r\n   </soapenv:Body>\r\n</soapenv:Envelope> ";
		System.out.println(reqBody);
		RequestBody body = RequestBody.create(mediaType, reqBody);
		Request request = new Request.Builder()
		  .url(digiSignUrl)
		  .post(body)
		  .addHeader("Content-Type", "text/xml;charset=UTF-8")
		  .addHeader("SOAPAction", "/GenericSigningAdaptor/Services/GenericSigningAdaptorService.serviceagent/GenericSigningAdaptorEndpoint/updateSignItems")
		  .addHeader("Accept-Encoding", "gzip,deflate")
		  .addHeader("Connection", "Keep-Alive")
		  .build();
		Response response;
		try {
			response = client.newCall(request).execute();
			status = true;
			System.out.println(response);
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		return status;
		
	}

}
