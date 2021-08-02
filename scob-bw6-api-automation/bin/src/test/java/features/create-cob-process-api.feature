Feature: Verify the nice way out scenarios for STP process in retailCustomerCheck

  Background: 
    * url baseUrl
    * print baseUrl
    * def dataPath = "classpath:tdm/test-data-"+environment+".json"
    * json testData = read(dataPath)
    * def SMSessionCreator = Java.type('utils.SMSessionCreator')
    * json createCobProcess = testData.create_cob_process

@create_cob_process   
  Scenario Outline: Check if the logged in IB customer is <executionKey> and should give <messageKey>
    Given path 'ssr/commercial-banking/cobrequest/v1'
    And def account = <account>
    And def pass = "<pass>"
    And def smsessionId = SMSessionCreator.userSession(account,pass,environment)
    And header Cookie = 'SMSession='+smsessionId
    And header UVID = '739837asdiuabsdfkaraterun73'
    And request {}
    When method post
    Then status <status>
    And match response.createCOBProcessResponse.messages.message[0].messageKey == "<messageKey>"
    And match response.createCOBProcessResponse.messages.message[0].messageType == "<messageType>"
    
    Examples:
    |createCobProcess|