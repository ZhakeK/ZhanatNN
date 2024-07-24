/**
 * Created by zhanat.kanatbekov on 24.07.2024.
 */

public with sharing class LeadTriggerHandler {

    /**
     * Author Zhanat Kanatbekov.
     * @param leads List of leads before update or insert
     * @description this method automatically fills country related fields on Leads.
     */
    public static void handleBeforeInsertUpdate(List<Lead> leads){

        Map<String, Country__c> countryMap = new Map<String, Country__c>();
        for (Lead lead : leads) {
            if (lead.Country != null && !countryMap.containsKey(lead.Country)) {
                countryMap.put(lead.Country, null);
            }
        }

        if (!countryMap.isEmpty()) {
            for (Country__c country : [SELECT Name, Capital__c, Region__c, RegionalBlocs__c, Alpha2Code__c, Alpha3Code__c FROM Country__c WHERE Name IN :countryMap.keySet()]) {
                countryMap.put(country.Name, country);
            }
        }

        for (Lead lead : leads) {
            if (countryMap.containsKey(lead.Country)) {
                Country__c country = countryMap.get(lead.Country);
                if (country != null) {
                    lead.Capital__c = country.Capital__c;
                    lead.Country_Region__c = country.Region__c;
                    lead.Country_RegionalBlocs__c = country.RegionalBlocs__c;
                    lead.Country_Alpha2Code__c = country.Alpha2Code__c;
                    lead.Country_Alpha3Code__c = country.Alpha3Code__c;

                }
            }
        }

    }

}