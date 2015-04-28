public with sharing class WuDashboardCtrl {		 
	
	public DateTime getlastUpdated() {
    	return Utility.lastUpdateMarketDatetime;
    }

public  DateTime lastupdate{
  	get{
  		return Utility.lastUpdateMarketDatetime;
  	}
  } 

}