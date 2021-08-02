Feature: Verify the maintenance api is working as expected

  Background: 
    * def SMSessionCreator = Java.type('utils.SMSessionCreator')
    * def insertRecToMaintenance = Java.type('utils.SCOBdbUpdate')
    
  Scenario: validate the loggedin ib customer must response with MESSAGE_BPMCOB_0000 success code in case the maintenance is not set for STP.
  	Given url baseUrl +':30383/'
  	And path 'maintenance/v1'
    And def account = "439215420"
    And def pass = "592"
    And def smsessionId = SMSessionCreator.userSession(account,pass,environment)
    And header SessionId = smsessionId
    And header UVID = '739837asdiuabsdfkaraterun73'
    When method get
    Then status 200
    And match response.maintenanceResponse.messages.message[0].messageKey == "MESSAGE_BPMCOB_0000"
    And def process_id = response.maintenanceResponse.cobProcessID
    
    # DIAL data validation
    Given url 'http://vm00006321:48134/'
    And path 'GetDialData/'+process_id
    When method get
    Then status 200
    And match response.DialDetailsResponse.process_details == '#[]'
    
    Scenario: validate the loggedin ib customer must response with MESSAGE_BPMCOB_1001 success code in case of technical error.
    Given url baseUrl +':30383/'
  	And path 'maintenance/v1'
    And def account = "439215420"
    And def pass = "592"
    And def smsessionId = SMSessionCreator.userSession(account,pass,environment)
    And header SessionId = 'fasd'+smsessionId
    And header UVID = '739837asdiuabsdfkaraterun73'
    When method get
    Then status 503
    And match response.maintenanceResponse.messages.message[0].messageKey == "MESSAGE_BPMCOB_1001"
    And def process_id = response.maintenanceResponse.cobProcessID
    
    
    Scenario: validate the loggedin ib customer must response with MESSAGE_BPMCOB_4012 success code in case the maintenance is set for STP.
  	Given url baseUrl +':30383/'
  	And path 'maintenance/v1'
    And def account = "439215420"
    And def pass = "592"
    And def insertStatus =  insertRecToMaintenance.insertRecordInMaintenance()
    And def smsessionId = SMSessionCreator.userSession(account,pass,environment)
    And header SessionId = smsessionId
    And header UVID = '739837asdiuabsdfkaraterun73'
    When method get
    Then status 500
    And match response.maintenanceResponse.messages.message[0].messageKey == "MESSAGE_BPMCOB_4012"
    And def process_id = response.maintenanceResponse.cobProcessID
    
    
    