/*
* Description :    Monitor Breadwinner Stripe Scheduled Batch Jobs
* This batch will check for all batch classes of Breadwinner. If no batch found or if it's next firetime null, it will reschedule.
*/

public with sharing class BreadwinnerMonitor implements Schedulable {
    public List<BreadwinnerUtil.AppConfig> appConfigList = new List<BreadwinnerUtil.AppConfig>();
    public Breadwinner_Settings__c bwSetting = new Breadwinner_Settings__c();
    
    public BreadwinnerMonitor() {
        try {
            if(BreadwinnerUtil.processorConfigList.size() > 0) {
                appConfigList.add(BreadwinnerUtil.getProcessorConfigWrapper(BreadwinnerUtil.processorConfigList[0]));
                bwSetting = Breadwinner_Settings__c.getAll().values().get(0);
            }
        } catch(Exception ex) {
            System.debug(ex);
        }
    }
    
    public void execute(SchedulableContext sc) {
        try {
            BreadwinnerUtil.deleteConfigsWhenSandboxRefresh();
            APICallHandler.asyncGetSFOrgInfo();
            //Check batches are in queue and NextFireTime is not null
            List<CronTrigger> listCronTrigger = BreadwinnerUtil.getCronTrigger(BreadwinnerUtil.SYNC_CNTX_HOURLY);
            Boolean scheduleHourlySync = false;
            for(CronTrigger ct : listCronTrigger) {    
                
                if(ct.NextFireTime == NULL) {
                    System.abortJob(ct.Id);
                    if(ct.CronJobDetail.Name.containsIgnoreCase(BreadwinnerUtil.SYNC_CNTX_HOURLY)) {
                        scheduleHourlySync = true;
                    }
                }
            }
            if(scheduleHourlySync || listCronTrigger.size() == 0) {
                HourlySyncBatch.scheduleBreadwinnerHourlySync(15, true);
            }
            //Schedule weekly sync
            HistoricalSyncBatch.scheduleWeeklyHistoricalSync();
            //Refresh the Access Token if needed
            HourlySyncBatch.checkAndRefreshAccessToken(BreadwinnerUtil.processorConfigList);

            sendLogForLast90DaysTotalAmountInCents();
            
        } catch(Exception ex) {
            System.debug(ex);
        }
    }

    private static void sendLogForLast90DaysTotalAmountInCents(){
        Set<String> createdViaBW = new Set<String> {BreadwinnerUtil.CNTX_BWAPI, BreadwinnerUtil.CNTX_BW};
        AggregateResult[] groupedResults = [SELECT SUM(Amount__c)totalAmt FROM BWP_Transaction__c WHERE createdDate = LAST_90_DAYS AND Amount__c!=NULL AND Created_Via__c IN : createdViaBW];
        Decimal last90DaysTotalAmount =0;

        for(AggregateResult aggr:groupedResults){
            if(aggr.get('totalAmt') != NULL)
                last90DaysTotalAmount+= (Decimal) aggr.get('totalAmt');
        }
        // Dollars to cents conversion
        last90DaysTotalAmount = last90DaysTotalAmount * 100;
        APICallHandler.userInteractionLogPush(FALSE, 'Payment Amount', ''+last90DaysTotalAmount , 'Total amount (in cents) collected from the Breadwinner in the last 90 days.');
        //return last90DaysTotalAmount;
    }
}