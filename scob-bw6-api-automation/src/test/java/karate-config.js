function() {   
	var config={}
	var env = karate.properties['karate.env'];
	karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'ST';
  }
  config = {
			msecUrl: 'http://msecwsinterst.nl.eu.abnamro.com:14029',
		    eidentifierUrl: 'https://vm00006525.nl.eu.abnamro.com:9100/e1_sim',
		    VMbaseUrl: 'http://vm00005504:',
		    baseUrl: 'http://portal-c19.nl.eu.abnamro.com:9997/',
		    digiSignUrl: 'http://vm00006321:9048'
  };
  if (env == 'UT') {
			config.msecUrl = 'http://msecwsinterst.nl.eu.abnamro.com:14029',
		    config.eidentifierUrl ='https://vm00006525.nl.eu.abnamro.com:9100/e1_sim',
		    config.VMbaseUrl = 'http://vm00005504:',
		    config.digiSignUrl= 'http://vm00006321:9048'
  } else if (env == 'ST') {
			config.msecUrl = 'http://msecwsinterst.nl.eu.abnamro.com:14029',
		    config.eidentifierUrl = 'https://vm00006525.nl.eu.abnamro.com:9100/e1_sim',
		    config.baseUrl = 'http://portal-c19.nl.eu.abnamro.com:9997/',
		    config.environment = env,
		    config.digiSignUrl= 'http://vm00006321:9048/GenericSigningAdaptor/Services/GenericSigningAdaptorService.serviceagent/GenericSigningAdaptorEndpoint'
  }else if (env == 'ET') {
	  	karate.configure('ssl', false)
       	karate.configure ('proxy' , 'http://nl-userproxy-access.net.abnamro.com:8080')
		config.msecUrl = 'http://msecwsintraet.nl.eu.abnamro.com:8081',
	    config.eidentifierUrl = 'http://mwr-et2.nl.eu.abnamro.com:8100/e1_sim',
	    config.baseUrl = 'https://www-et1.abnamro.nl/',
	    config.environment = env,
	    config.digiSignUrl= 'http://vm00006327:9048/GenericSigningAdaptor/Services/GenericSigningAdaptorService.serviceagent/GenericSigningAdaptorEndpoint'
}
  karate.log('karate.env system property was:', env);
  karate.configure('connectTimeout', 100000);
  karate.configure('readTimeout', 100000);
  return config;
}