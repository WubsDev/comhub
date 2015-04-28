/**=====================================================================
 * Name: AutoFollowTheRecords
 * Description: Related to AutoFollow invoice record on creation
 * Created Date: Feb 02, 2015
 * Created By: Nishant Bansal (JDC)
 * 
 * Date Modified                Modified By                  Description of the update
 * 12-02-2015                   Piyush Bansal                I-148276 resolution - upgraded API version to 29.0
                                                             added - follow.NetworkId = Network.getNetworkId();
 =====================================================================*/
public class AutoFollowTheRecords{
    public static void followRecords(set<Id> followIds,Id subscriberId){
        list<EntitySubscription> listEntitySubscription=new list<EntitySubscription>();
        set<Id> followupdoneIds = new set<Id>();
        try{
            // creating set of already follow up records
            for(EntitySubscription objEntitySubscription:[Select id,parentId from EntitySubscription 
            where parentId in:followIds]){
                followupdoneIds.add(objEntitySubscription.parentId);
            }
            // looping thru all followIds to create follow up records
            for(Id recid:followIds){                
                    // if no follow up records or not contains any invoice.id
                if(followupdoneIds.size()==0 || !followupdoneIds.contains(recid)){
                    // creating a EntitySubscription record to follow invoice
                    //recid='a1bS0000001fbPg';
                    System.debug('=======> recid '+recid);
                    System.debug('=======> subscriberId '+subscriberId); 
                   // if((recid == null) || (recid == ''))
                    //	continue;
                    listEntitySubscription.add(new EntitySubscription (ParentId = recid, SubscriberId =  subscriberId, NetworkId = Network.getNetworkId()));   
                    listEntitySubscription.add(new EntitySubscription (ParentId = recid, SubscriberId =  subscriberId));                
                }    
            }
            // insert records in Entity subscription
            if(listEntitySubscription.size()>0){
                insert listEntitySubscription;
            }
        }
        catch(exception ex){
            system.debug('Exception occur->'+ex);
        }
    }
    
}