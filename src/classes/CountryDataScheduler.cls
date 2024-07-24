/**
 * @author Zhanat.Kanatbekov on 21.07.2024.
 * @description For Scheduling CountryLayerService Class. Which will run once a doy.
 */

global class CountryDataScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        CountryLayerService.fetchCountryData();
    }
}