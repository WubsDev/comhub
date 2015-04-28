/**=====================================================================
 * Name: CustomPaginationController
 * 	CustomPaginationController for wrapper class
 * Created Date: March 28, 2015
 * Created By: Ranjeet Singh (JDC)
 *  
 * Date Modified                Modified By                  Description of the update
 
 =====================================================================*/
public with sharing class CustomPaginationController {
    public Paginate paginater {get;set;}
    public List<object> genericList{get;set;}
    public List<List<object>> fullGenericList{get;set;}
 	public Integer pageSize {get;set;}
 	public String previousSortField{get;set;}
	public String sortField {
		get  { if (sortField == null) {sortField = 'Transaction_Date__c'; previousSortField='';} return sortField;  }
		set{
			previousSortField=sortField;
			sortField=value;
		}
	}
    public void toggle(){
    	if(previousSortField==sortField){
    		sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
    	}else{
    		sortDir = 'asc';
    	}
    }
     // the current sort direction. defaults to asc
	public String sortDir {
		get  { if (String.isEmpty(sortDir)) {  sortDir = 'asc'; } return sortDir;  }
		set;
	}
      	
    public CustomPaginationController(Integer pageSize, List<object> genericList, List<List<object>> fullGenericList){
        //Set the page size
 		this.pageSize = pageSize;
 		this.genericList = genericList;
 		this.fullGenericList = fullGenericList;
    }
 
 	public void loadData(List<object> resultsList){
        //Create a new instance of Paginate passing in the overall size of
        //the list of data and the page size you want
        this.paginater = new Paginate(resultsList.size(), pageSize);
 		
 		if(this.fullGenericList!=null){
 			this.fullGenericList.clear();
 		}
 		if(this.genericList!=null){
 			this.genericList.clear();
 		}
        //These lists hold the data
        
        //Break out the full list into a list of lists
        if(resultsList.size() > 0){
            List<object> tempCC = genericList.clone();        
            tempCC.clear();
            Integer i = 0;
            for(object cc : resultsList){
                tempCC.add(cc);
                i++;
                if(i == pageSize){
                    this.fullGenericList.add(tempCC);
                    tempCC = genericList.clone();
                    tempCC.clear();
                    //new List<object>();
                    i = 0;
                }
            }
            if(!tempCC.isEmpty()){
                this.fullGenericList.add(tempCC);
            }
             
            //Gets the correct list of data to show on the page
            this.genericList = this.fullGenericList.get(this.paginater.index);
        } 		
 	}
    public void previousPage(){
        this.paginater.decrement();
        changeData();
    }
    public void lastPage(){
        this.paginater.pageNum = this.paginater.totalPage;
        this.paginater.updateNumbers();
        changeData();
    }
     
    public void firstPage(){
        this.paginater.pageNum = 1;
        this.paginater.updateNumbers();
        changeData();
    }
    public void nextPage(){
        this.paginater.increment();
        changeData();
    }
 
    public void updatePage(){
        this.paginater.updateNumbers();
        changeData();
    }
     
    public void changeData(){
        this.genericList = this.fullGenericList.get(this.paginater.index);
    }     
    
}