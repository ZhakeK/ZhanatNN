��#   Z h a n a t N N 
 
## Scheduling the Apex Job

To schedule the `CountryDataScheduler` Apex class, run the following anonymous Apex code:

```apex
String jobName = 'CountryDataUpdateJob';
String cronExpression = '0 0 0 * * ?'; // Daily at midnight

CountryDataScheduler scheduler = new CountryDataScheduler();
System.schedule(jobName, cronExpression, scheduler);
 
