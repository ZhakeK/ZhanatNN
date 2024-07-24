/**
 * @author Zhanat.Kanatbekov on 23.07.2024.
 * @description  Test class for CountryLayerService class
 */

@IsTest
public class CountryLayerServiceTest {

    @isTest
    static void testFetchCountryData() {
        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new CountryLayerHttpMock());

        // Call the method to fetch country data
        CountryLayerService.fetchCountryData();

        // Verify that the country data has been fetched and processed
        List<Country__c> countries = [SELECT Name, Alpha2Code__c, Alpha3Code__c, Capital__c, Region__c, RegionalBlocs__c FROM Country__c];
        System.assertEquals(0, countries.size());
    }

    @isTest
    static void testProcessCountryData() {
        String jsonResponse = '[{"name":"Test Country","alpha2Code":"TC","alpha3Code":"TCO","capital":"Test Capital","region":"Test Region","regionalBlocs":[{"acronym":"TB"}]}]';

        // Call the method to process country data
        CountryLayerService.processCountryData(jsonResponse);

        // Verify that the country data has been inserted/updated
        List<Country__c> countries = [SELECT Name, Alpha2Code__c, Alpha3Code__c, Capital__c, Region__c, RegionalBlocs__c FROM Country__c];
        System.assertEquals(1, countries.size());
        System.assertEquals('Test Country', countries[0].Name);
        System.assertEquals('TC', countries[0].Alpha2Code__c);
        System.assertEquals('TCO', countries[0].Alpha3Code__c);
        System.assertEquals('Test Capital', countries[0].Capital__c);
        System.assertEquals('Test Region', countries[0].Region__c);
        System.assertEquals('TB', countries[0].RegionalBlocs__c);
    }

    @isTest
    static void testGetCurrentCountryData() {
        // Create test data
        Country__c country = new Country__c(
                Name = 'Test Country',
                Alpha2Code__c = 'TC',
                Alpha3Code__c = 'TCO',
                Capital__c = 'Test Capital',
                Region__c = 'Test Region',
                RegionalBlocs__c = 'TB'
        );
        insert country;

        // Call the method to get current country data
        Map<String, Country__c> countryMap = CountryLayerService.getCurrentCountryData();

        // Verify the results
        System.assertEquals(1, countryMap.size());
        System.assertEquals('Test Country', countryMap.get('TC').Name);
    }

    @isTest
    static void testProcessCountryDataWithExistingData() {
        // Create existing data
        Country__c existingCountry = new Country__c(
                Name = 'Old Country',
                Alpha2Code__c = 'TC',
                Alpha3Code__c = 'OLD',
                Capital__c = 'Old Capital',
                Region__c = 'Old Region',
                RegionalBlocs__c = 'OB'
        );
        insert existingCountry;

        // New JSON response
        String jsonResponse = '[{"name":"Test Country","alpha2Code":"TC","alpha3Code":"TCO","capital":"Test Capital","region":"Test Region","regionalBlocs":[{"acronym":"TB"}]}]';

        // Call the method to process country data
        CountryLayerService.processCountryData(jsonResponse);

        // Verify that the existing data has been updated
        Country__c updatedCountry = [SELECT Name, Alpha2Code__c, Alpha3Code__c, Capital__c, Region__c, RegionalBlocs__c FROM Country__c WHERE Alpha2Code__c = 'TC' LIMIT 1];
        System.assertEquals('Test Country', updatedCountry.Name);
        System.assertEquals('TCO', updatedCountry.Alpha3Code__c);
        System.assertEquals('Test Capital', updatedCountry.Capital__c);
        System.assertEquals('Test Region', updatedCountry.Region__c);
        System.assertEquals('TB', updatedCountry.RegionalBlocs__c);
    }

    @isTest
    static void testProcessCountryDataWithoutChange() {
        // Create existing data that matches the JSON response
        Country__c existingCountry = new Country__c(
                Name = 'Test Country',
                Alpha2Code__c = 'TC',
                Alpha3Code__c = 'TCO',
                Capital__c = 'Test Capital',
                Region__c = 'Test Region',
                RegionalBlocs__c = 'TB'
        );
        insert existingCountry;

        // New JSON response matching the existing data
        String jsonResponse = '[{"name":"Test Country","alpha2Code":"TC","alpha3Code":"TCO","capital":"Test Capital","region":"Test Region","regionalBlocs":[{"acronym":"TB"}]}]';

        // Call the method to process country data
        CountryLayerService.processCountryData(jsonResponse);

        // Verify that no new data has been inserted/updated
        List<Country__c> countries = [SELECT Name, Alpha2Code__c, Alpha3Code__c, Capital__c, Region__c, RegionalBlocs__c FROM Country__c];
        System.assertEquals(1, countries.size());
        System.assertEquals('Test Country', countries[0].Name);
    }

    // Mock HTTP Response class
    public class CountryLayerHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"name":"Test Country","alpha2Code":"TC","alpha3Code":"TCO","capital":"Test Capital","region":"Test Region","regionalBlocs":[{"acronym":"TB"}]}]');
            res.setStatusCode(200);
            return res;
        }
    }
}