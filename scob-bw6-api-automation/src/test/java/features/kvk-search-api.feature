Feature: Verify the kvk search api responses

  Background:
    #  setting the url to the base url as per the environment
    * url baseUrl
    # load test data files as per the environment
    * def dataPath = "classpath:tdm/test-data-"+environment+".json"
    * json testData = read(dataPath)
    * def SMSessionCreator = Java.type('utils.SMSessionCreator')
    # setting up the test data set for kvkSearchAPI
    * json kvkSearchDataSet = testData.kvk_search
    # setting up the test data set for success account and pass for session creation
    * json successData = testData.sbcob_e2e

    #    the scenario is to execute all the possible cases for kvk search api
  @kvk-search @regression
  Scenario Outline: Check if the logged in IB customer is <executionKey> and should give <messageKey>
    #    the step to generate valid session by calling java function userSession which internally calls ciso api
    Given def smsessionId = SMSessionCreator.userSession(successData.account,successData.pass,environment)
#    the step is to call reusable create cob api scenario with sessionId as param and reponse is send back and store in result var
    When def result = call read('create-cob-process-api.feature@name=callCreateCobProcess') {sessionId: #(smsessionId)}
    Then def requestId = result.response.createCOBProcessResponse.requestId
    
     # validate the company, user has provided is available in kvk system and return few details
    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId+'/kvk/'+'<kvk>'
    And header Cookie = 'SMSession='+smsessionId
    When method get
    Then status <status>
    And match response.searchKvKResponse.messages.message[0].messageKey == "<messageKey>"
    And match response.searchKvKResponse.messages.message[0].messageType == "<messageType>"
    
    Examples:
    |kvkSearchDataSet|

  @name=callKvkSearch
  Scenario: search lite kvk call
    Given def result = call read('create-cob-process-api.feature@name=callCreateCobProcess') {sessionId: #(sessionId)}
    Then def requestId = result.response.createCOBProcessResponse.requestId
    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId+'/kvk/'+kvk
    And header Cookie = 'SMSession='+sessionId
    When method get
    Then status 200