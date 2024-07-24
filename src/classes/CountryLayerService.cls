/**
 * Created by zhanat.kanatbekov on 19.07.2024.
 */

/**
 * @author Zhanat Kanatbekov
 * @description The CountryLayerService class provides methods to fetch and update country data from the CountryLayer API.
 * @description If any data changed in CountryLayer in exact fields it will update or insert data.
 */
public with sharing class CountryLayerService {

    /**
     * @author Zhanat Kanatbekov
     *
      * @description Represents a Country with its relevant attributes, which will used for deserializing response from CountryLayer API.
      */
    public class Country {

        public String name;
        public String alpha2Code;
        public String alpha3Code;
        public String capital;
        public String region;
        public List<RegionalBloc> regionalBlocs;

    }

    /**
     * @author Zhanat Kanatbekov
     *
     * @description Represents a Regional Bloc with its acronym. Due to limited access to data now it fills empty.
     */
    public class RegionalBloc {

        public String acronym;

    }

    /**
     * @author Zhanat Kanatbekov
     *
    * @description Fetches country data from the CountryLayer API. Using future to be able schedule job.
    */
    @future(callout=true)
    public static void fetchCountryData() {
        String accessKey  = [SELECT ID,Access_Key__C FROM Country_Layer_API__mdt WHERE DeveloperName = 'CountryLayerAPI'].Access_Key__C;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = 'http://api.countrylayer.com/v2/all?access_key=' + accessKey;
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            processCountryData(responseBody);
        } else {
            System.debug('Error fetching country data: ' + response.getBody());
        }
    }

    /**
    * @author Zhanat Kanatbekov
     *
    * @description Retrieves the current country data stored in the custom object Country__c.
    *
    * @return A map of Alpha2Code__c to Country__c records.
    */
    public static Map<String, Country__c> getCurrentCountryData() {

        Map<String, Country__c> countryMap = new Map<String, Country__c>();

        for (Country__c country : [SELECT Id, Name, Alpha2Code__c, Alpha3Code__c, Capital__c, Region__c, RegionalBlocs__c FROM Country__c]) {
            countryMap.put(country.Alpha2Code__c, country);
        }
        return countryMap;
    }

    /**
     * @author Zhanat Kanatbekov
     *
     * @description Processes the country data received from the API and updates or inserts records to Country__c.
     *
     * @param responseBody The JSON response body from the CountryLayer API.
     */
    public static void processCountryData(String responseBody) {

        List<Country> countries = (List<Country>) JSON.deserialize(responseBody, List<Country>.class);

        Map<String, Country__c> currentCountries = getCurrentCountryData();

        List<Country__c> countryRecordsToUpdate = new List<Country__c>();

        for (Country country : countries) {
            List<String> acronyms = new List<String>();
            if (country.regionalBlocs != null) {
                for (RegionalBloc bloc : country.regionalBlocs) {
                    acronyms.add(bloc.acronym);
                }
            }

            String regionalBlocsAcronyms = String.join(acronyms, ';');

            Country__c existingCountry = currentCountries.get(country.alpha2Code);

            if (existingCountry == null ||
                    existingCountry.Name != country.name ||
                    existingCountry.Alpha3Code__c != country.alpha3Code ||
                    (existingCountry.Capital__c != country.capital && !String.isBlank(country.capital)) ||
                    (existingCountry.Region__c != country.region && !String.isBlank(country.region)) ||
                    (existingCountry.RegionalBlocs__c != regionalBlocsAcronyms &&!String.isBlank(regionalBlocsAcronyms))){

                Country__c countryRecord = new Country__c(
                        Name = country.name,
                        Alpha2Code__c = country.alpha2Code,
                        Alpha3Code__c = country.alpha3Code,
                        Capital__c = country.capital,
                        Region__c = country.region,
                        RegionalBlocs__c = regionalBlocsAcronyms
                );
                if (existingCountry != null) {
                    countryRecord.Id = existingCountry.Id;
                }
                countryRecordsToUpdate.add(countryRecord);
            }
        }

        if (!countryRecordsToUpdate.isEmpty()) {
            upsert countryRecordsToUpdate;
        }
    }
}