/**=====================================================================
 * Name: ParseAndDisplayCSVGenericTmpCtl
 * Description: 
 * Created Date: March 5, 2015
 * Created By: Ranjeet Singh (JDC)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
public with sharing class ParseAndDisplayCSVGenericTmpCtl {
	public String tmpCsv{get;set;}
	public ParseAndDisplayCSVGenericTmpCtl(){
		List<string>fieldnames = new List<string>();
		String tmp = '';
		tmpCsv ='';
		if(system.currentPageReference().getParameters().get('tmp') != null) {
    		tmp = System.currentPageReference().getParameters().get('tmp');
    	}
    	string objName = 'input__c';
    	if(tmp=='Invoice'){
    		objName = 'invoice__c';
    	}
    	if(!String.isEmpty(tmp)){
    		map<string, string>mapNames = Utility.getFieldLabel(objName, tmp);
    		tmp = Utility.changeTransactionType(tmp);
    		for(Schema.FieldSetMember f : Schema.getGlobalDescribe().get(objName).getDescribe().fieldSets.getMap().get(tmp).getFields()) {
    			if(!f.fieldPath.equalsIgnoreCase('Paid__c')){
    				fieldnames.add(mapNames.get(f.fieldPath));
	    			if(f.fieldPath.equalsIgnoreCase('Amount__c') && tmp.equalsIgnoreCase('Option_Other') ){
	     				fieldnames.add(mapNames.get(f.fieldPath+'_other'));
	     			}
    			}
    		}
    		if(fieldnames.size()>0){
    			tmpCsv= String.join(fieldnames, ',');
    		} 	
    	}
	}
}