Feature: Verify the nice way out scenarios for STP process in company eligibility api

  Background: 
    * url baseUrl
    * def dataPath = "classpath:tdm/test-data-"+environment+".json"
    * json testData = read(dataPath)
    * def SMSessionCreator = Java.type('utils.SMSessionCreator')
    * json companyEligibilityCheck = testData.company_elg_check
    * json successData = testData.sbcob_e2e
    * def BCDBUpdateKvk = Java.type('utils.BCDBDbUpdate')

@company_elg_check @regression
  Scenario Outline: Check if the logged in IB customer is <executionKey> and should give <messageKey>
    Given def db2updateResult = BCDBUpdateKvk.updateKvkInDb('<kvk>',environment)
    And def smsessionId = SMSessionCreator.userSession(successData.account,successData.pass,environment)
    When def result = call read('create-cob-process-api.feature@name=callCreateCobProcess') {sessionId: #(smsessionId)}
    Then def requestId = result.response.createCOBProcessResponse.requestId

     # Validate the company eligibility check service should give success response and the customer should eligible for requesting the business account.
    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId+'/companyEligibility'
    And param kvk = '<kvk>'
    And header Cookie = 'SMSession='+smsessionId
    When method get
    Then status <status>
    And match response.companyEligibilityResponse.messages.message[0].messageKey == "<messageKey>"
    And match response.companyEligibilityResponse.messages.message[0].messageType == "<messageType>"

    Examples:
    |companyEligibilityCheck|

  @name=callCompanyEligibility
    Scenario: call company eligibility
    When def result = call read('kvk-search-api.feature@name=callKvkSearch') {sessionId: #(sessionId), kvk: #(kvk)}
    Then def requestId = result.response.searchKvKResponse.requestId

    Given path 'ssr/commercial-banking/cobrequest/v1/'+requestId+'/companyEligibility'
    And param kvk = kvk
    And header Cookie = 'SMSession='+smsessionId
    When method get
    Then status 200

