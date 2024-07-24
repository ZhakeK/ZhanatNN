/**
 * @author Zhanat.Kanatbekov on 23.07.2024.
 * @description Test class for CountryDataScheduler class
 */

@IsTest
private class CountryDataSchedulerTest {

    @isTest
    static void testCountryDataScheduler() {
        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new CountryLayerServiceTest.CountryLayerHttpMock());

        // Schedule the job
        String jobId = System.schedule('CountryDataSchedulerJob', '0 0 0 * * ?', new CountryDataScheduler());

        // Retrieve the scheduled job
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 0 * * ?', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);

        // Simulate the job execution
        Test.startTest();
        CountryLayerService.fetchCountryData();
        Test.stopTest();

        // Verify that the country data has been fetched and processed
        List<Country__c> countries = [SELECT Name, Alpha2Code__c, Alpha3Code__c, Capital__c, Region__c, RegionalBlocs__c FROM Country__c];
        System.assertEquals(1, countries.size());
        System.assertEquals('Test Country', countries[0].Name);
    }
}