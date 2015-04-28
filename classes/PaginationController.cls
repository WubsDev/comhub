/**=====================================================================
 * Name: PaginationController
 * 	Pagenation controller Utility
 * Created Date: March 04, 2015
 * Created By: Ranjeet Singh (JDC)
 *  
 * Date Modified                Modified By                  Description of the update
 
 =====================================================================*/
public without sharing class PaginationController {
	public Integer avaliableRecord{get;set;}
	public Integer pageSize{get;set;}//InputViewPagesize
	public boolean isNavigate{get;set;}
	public String sortField {
		get  { if (sortField == null) {sortField = 'Transaction_Date__c'; } return sortField;  }
		set;
	}
     // the current sort direction. defaults to asc
	public String sortDir {
		get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
		set;
	}
     	
	public PaginationController(){
		
	}
	public PaginationController(Integer pgSize){
		pageSize = pgSize;
		isNavigate = true;
	}
	  public List<sObject> getList(){
	  	isNavigate = false;
	    if(setCon != null && setCon.getResultSize() > 0 && avaliableRecord>0){
	      return setCon.getRecords();
	    }	       
	    return new List<sObject>();
	  }
	  public ApexPages.StandardSetController setCon {
	    get {
	        if(setCon == null) {
	            setCon = new ApexPages.StandardSetController(new List<sObject>());
	        }
	        return setCon;
	    }set;
	  }


	public void generateData(String strQuery){
		try{
			isNavigate = true;
			setCon = new ApexPages.StandardSetController(Database.query(strQuery));
			setCon.setpagesize(pageSize);
		}catch(Exception Ex){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Detail '+Ex.getMessage()));
		}
	}
	public void generateData(List<sObject> objs){
		try{
			isNavigate = true;
			avaliableRecord = objs.size();
			setCon = new ApexPages.StandardSetController(objs);
			setCon.setpagesize(pageSize);
		}catch(Exception Ex){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Detail '+Ex.getMessage()));
		}
	}
	  
	
// Used in pagination of forward contract report
    public Boolean hasNext {
        get {
        	if(setCon==null){
        		return false;
        	}
            return setCon.getHasNext();
        }set;
    }

    public Boolean hasPrevious {
        get {
        	if(setCon==null){
        		return false;
        	}
            return setCon.getHasPrevious();
        }set;
    }

  public Integer pageNumber {
    get {
    	if(setCon==null){
    		return 0;
    	}
        return setCon.getPageNumber();
    }set;
  }

  public void first() {
  	isNavigate = true;
  	if(setCon!=null){
    	setCon.first();
  	}
  }

  public void last() {
  	isNavigate = true;
  	if(setCon!=null){
    	setCon.last();
  	}
  }

    public void previous() {
    	isNavigate = true;
        if(setCon!=null){
    		setCon.previous();
        }
    }

    public void next() {
    	isNavigate = true;
	  	if(setCon!=null){
	    	setCon.next();
	  	}
    }
}