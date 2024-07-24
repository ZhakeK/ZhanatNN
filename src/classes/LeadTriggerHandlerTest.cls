/**
 * @author Zhanat.Kanatbekov on 23.07.2024.
 * @DESCRIPTION  Test Class for LeadTriggerHandler.
 */

@IsTest
private class LeadTriggerHandlerTest {

    @isTest
    static void testLeadTrigger() {
        // Insert test country data
        Country__c testCountry = new Country__c(
                Name = 'Test Country',
                Alpha2Code__c = 'TC',
                Alpha3Code__c = 'TCO',
                Capital__c = 'Test Capital',
                Region__c = 'Test Region',
                RegionalBlocs__c = 'TB'
        );
        insert testCountry;

        // Insert test lead
        Lead testLead = new Lead(
                FirstName = 'John',
                LastName = 'Doe',
                Company = 'Test Company',
                Country = 'Test Country'
        );
        insert testLead;

        // Retrieve the lead and verify the fields are populated correctly
        testLead = [SELECT Capital__c, Country_Region__c, Country_RegionalBlocs__c, Country_Alpha2Code__c, Country_Alpha3Code__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        System.assertEquals('Test Capital', testLead.Capital__c);
        System.assertEquals('Test Region', testLead.Country_Region__c);
        System.assertEquals('TB', testLead.Country_RegionalBlocs__c);
        System.assertEquals('TC', testLead.Country_Alpha2Code__c);
        System.assertEquals('TCO', testLead.Country_Alpha3Code__c);
    }
}