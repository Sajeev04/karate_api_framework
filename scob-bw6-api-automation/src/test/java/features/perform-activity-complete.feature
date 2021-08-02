Feature: validate perform activity complete response

  Background:
    * url baseUrl
    * print baseUrl
    * def dataPath = "classpath:tdm/test-data-"+environment+".json"
    * json testData = read(dataPath)
    * def SMSessionCreator = Java.type('utils.SMSessionCreator')
    * json successData = testData.sbcob_e2e
    * def BCDBUpdateKvk = Java.type('utils.BCDBDbUpdate')
    * json performActivityConfirmDataSet = testData.perform_activity
    * def DigiSign = Java.type('utils.DigiSign')

  @perform-activity-confirm @regression
  Scenario Outline: Validate the perform activity confirm with <executionKey>
    * def db2updateResult = BCDBUpdateKvk.updateKvkInDb(<kvk>,environment)
    * def smsessionId = SMSessionCreator.userSession(successData.account,successData.pass,environment)
    When def result = call read('update-cob-process-api.feature@name=UpdateCObWithCaamlQuestions') {sessionId: #(smsessionId), kvk: '<kvk>', emailId: #(successData.email), phoneNo: #(successData.phone)}
    Then def requestId =  result.response.updateCOBProcessResponse.requestId

    When def result = call read('get-cob-process-api.feature@name=callGetCobProcess') {sessionId: #(smsessionId), requestId: #(requestId), filteroption: 'bookkeepingEligibility'}
    And match result.response.getCOBProcessResponse.additionalInformation.nameValuePair[0].name == 'BOOKKEEPING_ELIGIBILITY'
    And match result.response.getCOBProcessResponse.additionalInformation.nameValuePair[0].value == '<bookkeepingFlag>'

    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId+'/activity'
    And header Cookie = 'SMSession='+smsessionId
    And def req = <payloadReq>
    And request req
    When method put
    Then status 200
    Then match response.performActivityResponse.messages.message[0].messageKey == 'MESSAGE_BPMCOB_0000'
    And match response.performActivityResponse.messages.message[0].messageType == 'INFO'

    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId+'/activity'
    And header Cookie = 'SMSession='+smsessionId
    And def req = {"performActivityRequest": {"action": "CONFIRM"}}
    And request req
    When method put
    Then status 200
    Then match response.performActivityResponse.messages.message[0].messageKey == 'MESSAGE_BPMCOB_0000'
    And match response.performActivityResponse.messages.message[0].messageType == 'INFO'
    And match response.performActivityResponse.nameValuePair[0].name == 'SIGNITEM_ID'
    And def signItemId = response.performActivityResponse.nameValuePair[0].value
    Then def result = call read('get-cob-process-api.feature@name=callGetCobProcess') {sessionId: #(smsessionId), requestId: #(requestId), filteroption: ''}
    And def contractId = result.response.getCOBProcessResponse.documents.document[0].id

    And def signingStatus = DigiSign.performDigiSign(digiSignUrl,smsessionId,successData.bc,successData.account+'_'+successData.pass,signItemId,contractId)

    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId+'/activity'
    And header Cookie = 'SMSession='+smsessionId
    And def req = {"performActivityRequest": {"action": "COMPLETE"}}
    And request req
    When method put
    Then status 200
    And match response.performActivityResponse.messages.message[0].messageKey == "MESSAGE_BPMCOB_0000"
    And match response.performActivityResponse.messages.message[0].messageType == "INFO"

    Examples:
      |performActivityConfirmDataSet|

    @name=callPerformActivityComplete
    Scenario: call perform activity confirm
    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId+'/activity'
    And header Cookie = 'SMSession='+sessionId
    And def req = {"performActivityRequest": {"action": "COMPLETE"}}
    And request req
    When method put
    Then status 200