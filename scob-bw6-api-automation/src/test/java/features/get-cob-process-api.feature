Feature: Validate the get cob process api response

  Background: 
    * url baseUrl
    * print baseUrl
    * def dataPath = "classpath:tdm/test-data-"+environment+".json"
    * json testData = read(dataPath)
    * def SMSessionCreator = Java.type('utils.SMSessionCreator')
    * json successData = testData.sbcob_e2e
    * def smsessionId = SMSessionCreator.userSession(successData.account,successData.pass,environment)

  @get_cob_process @regression
  Scenario: Validate the get cob response once create cob process is success
    Given def result = call read('create-cob-process-api.feature@name=callCreateCobProcess') {sessionId: #(smsessionId)}
    Then def requestId = result.response.createCOBProcessResponse.requestId
   
    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId
    And header Cookie = 'SMSession='+smsessionId
    When method get
    Then status 200
    And match response.getCOBProcessResponse.requestState == "INITIALIZED"
    And match response.getCOBProcessResponse.messages.message[0].messageKey == "MESSAGE_BPMCOB_0000"
    And match response.getCOBProcessResponse.messages.message[0].messageType == "INFO"
    #And match response.getCOBProcessResponse.companyDetails == {}
    #And match response.getCOBProcessResponse.communicationDetails == {}
    And match response.getCOBProcessResponse.documents == {}
    And match response.getCOBProcessResponse.additionalInformation == {}

  @get_cob_process @regression
  Scenario: Validate the get cob response once create kvk search api is success
    Given def result = call read('kvk-search-api.feature@name=callKvkSearch') {sessionId: #(smsessionId), kvk: #(successData.kvk)}
    Then def requestId = result.response.searchKvKResponse.requestId

    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId
    And header Cookie = 'SMSession='+smsessionId
    When method get
    Then status 200
    And match response.getCOBProcessResponse.requestState == "INITIALIZED"
    And match response.getCOBProcessResponse.messages.message[0].messageKey == "MESSAGE_BPMCOB_0000"
    And match response.getCOBProcessResponse.messages.message[0].messageType == "INFO"

 @get_cob_process @regression
  Scenario: Validate the get cob response after company eligibility is successfull
   When def result = call read('company-eligibility-api.feature@name=callCompanyEligibility') {sessionId: #(smsessionId), kvk: #(successData.kvk)}
   Then def requestId = result.response.companyEligibilityResponse.requestId

    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId
    And header Cookie = 'SMSession='+smsessionId
    And header UVID = '739837asdiuabsdfkaraterun73'
    When method get
    Then status 200
    And match response.getCOBProcessResponse.requestState == "ELIGIBLE"
    And match response.getCOBProcessResponse.messages.message[0].messageKey == "MESSAGE_BPMCOB_0000"
    And match response.getCOBProcessResponse.messages.message[0].messageType == "INFO"
    And match response.getCOBProcessResponse.companyDetails.kvkNumber != ''
    And match response.getCOBProcessResponse.companyDetails.ownerDetails != {}
    And match response.getCOBProcessResponse.companyDetails.address == '#[2]'
    And match response.getCOBProcessResponse.communicationDetails == { "emailID": "##string", "contactNumber": "##string" }
    And match response.getCOBProcessResponse.documents == {}
    And match response.getCOBProcessResponse.additionalInformation == {}

@get_cob_process @regression
  Scenario: Validate the get cob response after company eligibility is successfull with filter options
    When def result = call read('company-eligibility-api.feature@name=callCompanyEligibility') {sessionId: #(smsessionId), kvk: #(successData.kvk)}
    Then def requestId = result.response.companyEligibilityResponse.requestId

    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId+'?filter=companyDetails'
    And header Cookie = 'SMSession='+smsessionId
    When method get
    Then status 200
    And match response.getCOBProcessResponse.requestState == "ELIGIBLE"
    And match response.getCOBProcessResponse.messages.message[0].messageKey == "MESSAGE_BPMCOB_0000"
    And match response.getCOBProcessResponse.messages.message[0].messageType == "INFO"
    And match response.getCOBProcessResponse.companyDetails.kvkNumber != ''
    And match response.getCOBProcessResponse.companyDetails.ownerDetails != {}
    And match response.getCOBProcessResponse.companyDetails.address == '#[2]'
    * def communicationDetailsSchema = {communicationDetails: { "emailID": "##string", "contactNumber": "##string" }}
    And match response.getCOBProcessResponse !contains communicationDetailsSchema

    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId+'?filter=communicationDetails'
    And header Cookie = 'SMSession='+smsessionId
    When method get
    Then status 200
    And match response.getCOBProcessResponse.requestState == "ELIGIBLE"
    And match response.getCOBProcessResponse.messages.message[0].messageKey == "MESSAGE_BPMCOB_0000"
    And match response.getCOBProcessResponse.messages.message[0].messageType == "INFO"
    * def communicationDetailsSchema = {communicationDetails: { "emailID": "##string", "contactNumber": "##string" }}
    And match response.getCOBProcessResponse contains communicationDetailsSchema
    * def companyDetailsSchema = { requestId: "#present", requestState: "#present", companyDetails: "#notpresent",communicationDetails: "#present", messages:"#present" }
    And match response.getCOBProcessResponse == companyDetailsSchema

  @name=callGetCobProcess
  Scenario: call getCObProcess
    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId+'?filter='+filteroption
    And header Cookie = 'SMSession='+sessionId
    When method get
    Then status 200