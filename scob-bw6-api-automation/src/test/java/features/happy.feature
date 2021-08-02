Feature: Validate the happy flow for scob application

  Background: 
    * url baseUrl
    # loading test data as per the environment
    * def dataPath = "classpath:tdm/test-data-"+environment+".json"
    * json testData = read(dataPath)
    * def scobSuccessData = get testData.sbcob_e2e
    * def SMSessionCreator = Java.type('utils.SMSessionCreator')
    * def DigiSign = Java.type('utils.DigiSign')
    * def BCDBUpdateKvk = Java.type('utils.BCDBDbUpdate')
    * def db2updateResult = BCDBUpdateKvk.updateKvkInDb(scobSuccessData.kvk,environment)
    * def waitfn = function(pause){ java.lang.Thread.sleep(pause) }
    
 @happy-flow   
  Scenario: Validate user can successfully able to onboard using scob application apis

    Given def smsessionId = SMSessionCreator.userSession(scobSuccessData.account,scobSuccessData.pass,environment)
   # calling reusable 2nd update for caaml questions
    When def result = call read('update-cob-process-api.feature@name=UpdateCObWithCaamlQuestions') {sessionId: #(smsessionId), kvk: #(scobSuccessData.kvk), emailId: #(scobSuccessData.email), phoneNo: #(scobSuccessData.phone)}
    Then def requestId =  result.response.updateCOBProcessResponse.requestId

#  calling get method from bookeeping eligibility check
   When def result = call read('get-cob-process-api.feature@name=callGetCobProcess') {sessionId: #(smsessionId), requestId: #(requestId), filteroption: 'bookkeepingEligibility'}
   And match result.response.getCOBProcessResponse.additionalInformation.nameValuePair[0].name == 'BOOKKEEPING_ELIGIBILITY'
   And match result.response.getCOBProcessResponse.additionalInformation.nameValuePair[0].value == 'Y'

# calling perform activity submit without bookkeeping opted
   When def result = call read('perform-activity-submit.feature@name=callPerformActivitySubmitWithBookeepingNotOpted') {sessionId: #(smsessionId),  requestId: #(requestId)}
   Then match result.response.performActivityResponse.messages.message[0].messageKey == 'MESSAGE_BPMCOB_0000'
   And match result.response.performActivityResponse.messages.message[0].messageType == 'INFO'

# calling get method to validate the states without bookkeeping opted
   When def result = call read('get-cob-process-api.feature@name=callGetCobProcess') {sessionId: #(smsessionId), requestId: #(requestId), filteroption: ''}
   And match result.response.getCOBProcessResponse.messages.message[0].messageKey == "MESSAGE_BPMCOB_0000"
   And match result.response.getCOBProcessResponse.messages.message[0].messageType == "INFO"
   And match result.response.getCOBProcessResponse.documents.document[0].type == "CONTRACT"
   And def contractId = result.response.getCOBProcessResponse.documents.document[0].id
   And result.response.getCOBProcessResponse.requestState == "SUBMITTED"

   # calling perform activity confirm
   When def result = call read('perform-activity-confirm.feature@name=callPerformActivityConfirm') {sessionId: #(smsessionId),  requestId: #(requestId)}
   Then match result.response.performActivityResponse.messages.message[0].messageKey == 'MESSAGE_BPMCOB_0000'
   And match result.response.performActivityResponse.messages.message[0].messageType == 'INFO'
   And match result.response.performActivityResponse.nameValuePair[0].name == "SIGNITEM_ID"
   And def signItemId = result.response.performActivityResponse.nameValuePair[0].value

#   calling getcob process to validate the state
   When def result = call read('get-cob-process-api.feature@name=callGetCobProcess') {sessionId: #(smsessionId), requestId: #(requestId), filteroption: ''}
   And match result.response.getCOBProcessResponse.messages.message[0].messageKey == "MESSAGE_BPMCOB_0000"
   And match result.response.getCOBProcessResponse.messages.message[0].messageType == "INFO"
   And result.response.getCOBProcessResponse.requestState == "CONFIRMED"

#    calling signinig feature to sign the process
    And def signingStatus = DigiSign.performDigiSign(digiSignUrl,smsessionId,scobSuccessData.bc,scobSuccessData.account+'_'+scobSuccessData.pass,signItemId,contractId)
    * print signingStatus
    And call waitfn(10000)

#   calling perform activity complete
   When def result = call read('perform-activity-complete.feature@name=callPerformActivityComplete') {sessionId: #(smsessionId),  requestId: #(requestId)}
   Then match result.response.performActivityResponse.messages.message[0].messageKey == 'MESSAGE_BPMCOB_0000'
   And match result.response.performActivityResponse.messages.message[0].messageType == 'INFO'

#   calling getcob process to validate the state
   When def result = call read('get-cob-process-api.feature@name=callGetCobProcess') {sessionId: #(smsessionId), requestId: #(requestId), filteroption: ''}
   And match result.response.getCOBProcessResponse.messages.message[0].messageKey == "MESSAGE_BPMCOB_0000"
   And match result.response.getCOBProcessResponse.messages.message[0].messageType == "INFO"
   And result.response.getCOBProcessResponse.requestState == "COMPLETED"
    
    
    
    
    
    
    
    
    