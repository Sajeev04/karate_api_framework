Feature: Validate the update cob process api response

  Background: 
    * url baseUrl
    * print baseUrl
    # loading the test data as per the environment
    * def dataPath = "classpath:tdm/test-data-"+environment+".json"
    * json testData = read(dataPath)
    * def successData = get testData.sbcob_e2e
    * def SMSessionCreator = Java.type('utils.SMSessionCreator')
    * def DigiSign = Java.type('utils.DigiSign')
    * def BCDBUpdateKvk = Java.type('utils.BCDBDbUpdate')
    * def db2updateResult = BCDBUpdateKvk.updateKvkInDb(successData.kvk,environment)
    * def smsessionId = SMSessionCreator.userSession(successData.account,successData.pass,environment)

  @update_cob_process @regression
  Scenario: Validate the update Cob api updates the phone number and email id correctly
    Given def result = call read('update-cob-process-api.feature@name=UpdateCObWithPhoneAndEmailId') {sessionId: #(smsessionId), kvk: #(successData.kvk), emailId: #(successData.email), phoneNo: #(successData.phone)}
    And match result.response.updateCOBProcessResponse.messages.message[0].messageKey == "MESSAGE_BPMCOB_0000"
    Then def requestId =  result.response.updateCOBProcessResponse.requestId

    When def result = call read('get-cob-process-api.feature@name=callGetCobProcess') {sessionId: #(smsessionId), requestId: #(requestId), filteroption: 'communicationDetails'}
    And match result.response.getCOBProcessResponse.requestState == "DATA_ENTRY"
    Then match result.response.getCOBProcessResponse.communicationDetails.emailID == "t@t.com"
    And match result.response.getCOBProcessResponse.communicationDetails.contactNumber == "+31685568349"

  @update_cob_process @regression
  Scenario: Validate the update Cob api updates caamlQuestions correctly
    Given def result = call read('update-cob-process-api.feature@name=UpdateCObWithCaamlQuestions') {sessionId: #(smsessionId), kvk: #(successData.kvk), emailId: #(successData.email), phoneNo: #(successData.phone)}
    And match result.response.updateCOBProcessResponse.messages.message[0].messageKey == "MESSAGE_BPMCOB_0000"
    Then def requestId =  result.response.updateCOBProcessResponse.requestId

    When def result = call read('get-cob-process-api.feature@name=callGetCobProcess') {sessionId: #(smsessionId), requestId: #(requestId), filteroption: ''}
    And match result.response.getCOBProcessResponse.requestState == "DATA_ENTRY_COMPLETED"


  @name=UpdateCObWithPhoneAndEmailId
  Scenario: Call update service to update email and phone number
    Given def result = call read('company-eligibility-api.feature@name=callCompanyEligibility') {sessionId: #(sessionId), kvk: #(kvk)}
    When def requestId = result.response.companyEligibilityResponse.requestId
    Then def result = call read('get-cob-process-api.feature@name=callGetCobProcess') {sessionId: #(sessionId), requestId: #(requestId), filteroption: ''}

    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId
    And header Cookie = 'SMSession='+smsessionId
    And def req = {"updateCOBProcessRequest":{"requestDetails":{"communicationDetails":{"emailID":"#(emailId)","contactNumber":"#(phoneNo)"}}}}
    And request req
    When method put
    Then status 200


  @name=UpdateCObWithCaamlQuestions
  Scenario: Call update service to update email and phone number
    Given def result = call read('company-eligibility-api.feature@name=callCompanyEligibility') {sessionId: #(sessionId), kvk: #(kvk)}
    When def requestId = result.response.companyEligibilityResponse.requestId
    Then def result = call read('get-cob-process-api.feature@name=callGetCobProcess') {sessionId: #(sessionId), requestId: #(requestId), filteroption: ''}

    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId
    And header Cookie = 'SMSession='+smsessionId
    And def req = {"updateCOBProcessRequest":{"requestDetails":{"communicationDetails":{"emailID":"#(emailId)","contactNumber":"#(phoneNo)"}}}}
    And request req
    When method put
    Then status 200

    And def result = call read('get-cob-process-api.feature@name=callGetCobProcess') {sessionId: #(sessionId), requestId: #(requestId), filteroption: ''}

    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId
    And header Cookie = 'SMSession='+smsessionId
    And def req = read('classpath:files/updateRequest.json')
    And request req
    When method put
    Then status 200