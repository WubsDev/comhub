public with sharing class WuDashboardCtrl {		 
	
	public String getlastUpdated() {
    	if(Utility.lastUpdateMarketDatetime != null){
  			return Utility.lastUpdateMarketDatetime.format();
  		}else{
  			return '';
  		}
    }

	public  String lastupdate{
  	get{
	  		if(Utility.lastUpdateMarketDatetime != null){
	  			return Utility.lastUpdateMarketDatetime.format();
	  		}else{
	  			return '';
	  		}
  	}
  } 

}