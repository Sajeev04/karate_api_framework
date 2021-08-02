Feature: Verify the nice way out scenarios for STP process in create cob process api

  Background:
    # setting the url to the base url as per the environment
    * url baseUrl
    # load test data files as per the environment
    * def dataPath = "classpath:tdm/test-data-"+environment+".json"
    * json testData = read(dataPath)
    * def SMSessionCreator = Java.type('utils.SMSessionCreator')
    # setting up the test data set for create cob process
    * json createCobProcess = testData.create_cob_process
    #    * configure abortedStepsShouldPass = true


#    the scenario is to execute all the possible cases for create cob process api
  @create_cob_process  @regression
  Scenario Outline: Check if the logged in IB customer is <executionKey> and should give <messageKey>
    #    this is for in case we would like to skip few scenario we have to make runFlag in test data sheet to true which will basically skip the sceanrio
    #    * if(!<runFlag>) karate.abort()
    Given path 'ssr/commercial-banking/cobrequest/v1'
    And def account = <account>
    And def pass = "<pass>"
    #    the step to generate valid session by calling java function userSession which internally calls ciso api
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

#    reusable create cob api call(this is used in case we would like to call create cob api from another feature file)
  @name=callCreateCobProcess
  Scenario: Create cob process call
    Given path 'ssr/commercial-banking/cobrequest/v1'
    And header Cookie = 'SMSession='+sessionId
    And header UVID = '739837asdiuabsdfkaraterun73'
    And request {}
    When method post
    Then status 200

