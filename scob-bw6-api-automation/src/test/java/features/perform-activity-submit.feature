Feature: validate perform activity submit response

  Background:
    * url baseUrl
    * print baseUrl
    * def dataPath = "classpath:tdm/test-data-"+environment+".json"
    * json testData = read(dataPath)
    * def SMSessionCreator = Java.type('utils.SMSessionCreator')
    * json successData = testData.sbcob_e2e
    * json evaRdcHit = testData.eva_rdc_hit
    * def BCDBUpdateKvk = Java.type('utils.BCDBDbUpdate')
    * json performActivitySubmitDataSet = testData.perform_activity

  @perform-activity-submit @regression
  Scenario Outline: Validate the perform activity submit with <executionKey>
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

    Examples:
    |performActivitySubmitDataSet|

    @name=callPerformActivitySubmitWithBookeepingNotOpted
    Scenario: call performactivity submit
      Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId+'/activity'
      And header Cookie = 'SMSession='+sessionId
      And def req = {"performActivityRequest":{"action":"SUBMIT"}}
      And request req
      When method put
      Then status 200

  @name=callPerformActivitySubmitWithBookkeepingOpted
  Scenario: call performactivity submit
    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId+'/activity'
    And header Cookie = 'SMSession='+sessionId
    And def req = {"performActivityRequest":{"action":"SUBMIT","nameValuePair":[{"name":"BOOKKEEPING_OPTED","value":"Y"},{"name":"BOOKKEEPING_PRODUCT_TYPE","value":"004406"}]}}
    And request req
    When method put
    Then status 200