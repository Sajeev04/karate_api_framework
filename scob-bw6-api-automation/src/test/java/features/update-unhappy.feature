Feature: Validate the get cob process api response

  Background:
    * url baseUrl
    * print baseUrl
    * def dataPath = "classpath:tdm/test-data-"+environment+".json"
    * json testData = read(dataPath)
    * def BCDBUpdateKvk = Java.type('utils.BCDBDbUpdate')
    * def SMSessionCreator = Java.type('utils.SMSessionCreator')
    * json unhappyDataSet = testData.unhappy

  Scenario Outline: Validate unhappy flow SB COB application for the <executionKeys> customer and the update service should return response code <messageKey>
    Given def db2updateResult = BCDBUpdateKvk.updateKvkInDb(<kvk>,environment)
    And def smsessionId = SMSessionCreator.userSession(<account>,<pass>,environment)

    When def result = call read('update-cob-process-api.feature@name=UpdateCObWithCaamlQuestions') {sessionId: #(smsessionId), kvk: '<kvk>', emailId: 't@t.com', phoneNo: '+31685568349'}
    Then def requestId =  result.response.updateCOBProcessResponse.requestId
    And match result.response.updateCOBProcessResponse.messages.message[*].messageKey contains ["MESSAGE_BPMCOB_5555",<messageKey>]

    When def result = call read('get-cob-process-api.feature@name=callGetCobProcess') {sessionId: #(smsessionId), requestId: #(requestId), filteroption: ''}
    Then print result
    Examples:
    |unhappyDataSet|