/**
 * Created by zhanat.kanatbekov on 21.07.2024.
 */

trigger LeadTrigger on Lead (before insert, before update) {

    LeadTriggerHandler.handleBeforeInsertUpdate(Trigger.new);

}