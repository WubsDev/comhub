/**=====================================================================
 * Name: TopPendingInvoicesCtrl
 * Description: Related to TopPendingInvoices Page
 * Created Date: Jan 15, 2015
 * Created By: Nishant Bansal (JDC)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
public without sharing class TopPendingInvoicesCtrl {
	
    public Id accId {get;set;}
    public List<InvoiceWrapper> invoiceList{get;set;}
    public Invoice__c invoice{get;set;}
    public String selectedStatus{get;set;}
    public String userDefaultCurrency{get;set;}
    public String userLanguage{get;set;}
     
    public TopPendingInvoicesCtrl() {
        userLanguage = UserInfo.getLanguage();
        if(userLanguage.trim() == 'fr'|| userLanguage.trim() == 'it'){
            userLanguage = '_'+userLanguage;
        }
        else{
            userLanguage = '';
        }
        invoice = new Invoice__c();
        userDefaultCurrency = UserInfo.getDefaultCurrency();
        selectedStatus = 'Both'; 
        User userLoggedIn = [Select Name,contactId, contact.AccountId FROM User WHERE id =: UserInfo.getUserId()];
        accId = userLoggedIn.Contact.AccountId;
        invoiceList = new List<InvoiceWrapper>();
        search();
    }
     
    // populate the top 5 invoices on the basis of due date and amount     
    public void search() {
        Set<String> stset = new Set<String>();
        invoiceList = new List<InvoiceWrapper>();
        if(selectedStatus == 'Both') {
            stset.add('Pending Approval (Open)');
            stset.add('Approved');
        }
        else {
            stset.add(selectedStatus);
        }
        System.debug('----------------> ' + stset);
        for(Invoice__c record: [SELECT id,Name, Custom_Currency__c, Due_Date__c, Amount__c,Input_Beneficiary__r.id,Input_Beneficiary__r.name, Status__c 
                        FROM Invoice__c 
       					WHERE Status__c In :stset
                        //AND Due_Date__c<=TODAY
                        AND Account__c =: accId
                         ORDER BY Due_Date_Span__c asc, Amount__c DESC
                        //ORDER BY Due_Date__c desc, Amount__c DESC 
                        LIMIT 5]){
            invoiceList.add(new InvoiceWrapper(record));                        
        }
        
    }
   
    public Boolean dataAvailable {
        get {  
            if(invoiceList.size() > 0) return true;
            else return false;
        }
    }
    
    public class InvoiceWrapper{
        public Invoice__c invoice{get;set;}
        public Decimal settlementCurrency{get;set;}
        public String settlementCurrencyFormat{get;set;}
        
        public InvoiceWrapper(Invoice__c invoice){
            this.invoice = invoice;
            settlementCurrency = Utility.getSettlementCurrencyAmount(invoice.Amount__c, invoice.Custom_Currency__c, UserInfo.getDefaultCurrency());
            settlementCurrencyFormat = settlementCurrency.format();
        }
    }
    
    
    
/*	public class InvoiceWpr implements Comparable{
   		public Invoice__c Invoice{get;set;}
   		public Integer diferenceDate{get;set;}
   		public Integer diferenceDateThis{get;set;}
   		public InvoiceWpr(Invoice__c InvoiceP){
   			Invoice = InvoiceP;
   		}
		public Integer compareTo(Object compareTo) {
            InvoiceWpr compareToEmp = (InvoiceWpr)compareTo;
            diferenceDate = System.today();
            if(compareToEmp.Due_Date__c>System.today()){
            	diferenceDate = compareToEmp.Due_Date__c -System.today(); 
            }else{
            	diferenceDate = System.today()- compareToEmp.Due_Date__c;
            }
            
            if (invYear > compareToEmp.invYear) return 1;
            if (invYear == compareToEmp.invYear)
            {
                if (invMonth == compareToEmp.invMonth) return 0;
                if (invMonth > compareToEmp.invMonth) return 1;
                return -1;
            }
            return -1;        
        }   		
   	}   */

}