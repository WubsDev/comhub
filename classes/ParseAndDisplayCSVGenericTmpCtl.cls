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
	public String langCode {get; set;}
	
	public ParseAndDisplayCSVGenericTmpCtl(){
		List<string>fieldnames = new List<string>();
		String tmp = '';
		tmpCsv ='';
		langCode = [SELECT LanguageLocaleKey from User where Id =:UserInfo.getUserId()].LanguageLocaleKey;
		if(system.currentPageReference().getParameters().get('tmp') != null) {
    		tmp = System.currentPageReference().getParameters().get('tmp');
    	}
    	string objName = 'input__c';
    	if(tmp=='Invoice'){
    		objName = 'invoice__c';
    	}
    	if(!String.isEmpty(tmp)){
    		map<string, string>mapNames = Utility.getFieldLabel(objName, tmp);
    		String tranType = tmp;//Forecast Inflow
    		tmp = Utility.changeTransactionType(tmp);//Get field-set.
    		for(Schema.FieldSetMember f : Schema.getGlobalDescribe().get(objName).getDescribe().fieldSets.getMap().get(tmp).getFields()) {
    			//Allow paid "Forecast Inflow"
    			/*if(f.fieldPath.equalsIgnoreCase('Paid__c')){
    				if('Forecast Inflow'.equalsIgnoreCase(tranType)){
    					fieldnames.add(mapNames.get(f.fieldPath)+'(Yes/No)');
    				}
    			}else{*/
    				fieldnames.add(mapNames.get(f.fieldPath));
    			// }
	    			if(f.fieldPath.equalsIgnoreCase('Amount__c') && tmp.equalsIgnoreCase('Option_Other') ){
	     				fieldnames.add(mapNames.get(f.fieldPath+'_other'));
	     			}
    			}
    		if(fieldnames.size()>0){
           		tmpCsv= String.join(fieldnames, Utility.CSVRowDeliminator);
    		} 	
            	//0d ->13
            	//0a ->10
				//tmpCsv = tmpCsv + String.fromCharArray(chars);
    	}
	}
}