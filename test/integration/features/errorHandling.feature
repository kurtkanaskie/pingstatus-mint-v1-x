@errorHandling
Feature: Error handling
	As an API consumer
	I want consistent and meaningful error responses
	So that I can handle the errors correctly

	@foo
    Scenario: GET /foo request not found
        Given I set X-APIKey header to `clientId`
        When I GET /foo
        Then response code should be 401
        And response header Content-Type should be application/json
        And response body path $.message should be Invalid API Key for given resource

    @post-foo
    Scenario: DELETE /foo request not found
        Given I set X-APIKey header to `clientId`
        When I DELETE /foo
        Then response code should be 401
        And response header Content-Type should be application/json
        And response body path $.message should be Invalid API Key for given resource
        
	@foobar
    Scenario: GET /foo/bar request not found
        Given I set X-APIKey header to `clientId`
        When I GET /foo/bar
        Then response code should be 401
        And response header Content-Type should be application/json
        And response body path $.message should be Invalid API Key for given resource

    @foobar
    Scenario: GET /foo/bar request not found
        Given I set X-APIKey header to `clientId`
        When I GET /foo/bar
        Then I should get a 401 error with message "Invalid API Key for given resource" and code "401.005"
        
