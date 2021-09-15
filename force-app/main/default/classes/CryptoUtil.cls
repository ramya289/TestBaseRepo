@namespaceAccessible
public with sharing class CryptoUtil {

    @testVisible 
    private static Map<String,String> cryptoKeyMap{
        get{
            if(cryptoKeyMap == NULL){
                Map<String,String> cKeyMap = new Map<String,String>();
                for(Breadwinner_Payments_Metadata__mdt cKeyHexRecord : [SELECT DeveloperName, Key__c FROM Breadwinner_Payments_Metadata__mdt WHERE DeveloperName IN ('Crypto_Key','Crypto_Key_Legacy')]){
                    cKeyMap.put(cKeyHexRecord.DeveloperName,cKeyHexRecord.Key__c);
                }
                cryptoKeyMap = cKeyMap;
            }
            return cryptoKeyMap;
        }
        set;
    }


    // This method can be called from Breadwinner Controller
    @namespaceAccessible
    public static BreadwinnerUtil.AppConfig encryptSecrets(BreadwinnerUtil.AppConfig ac) {
        if(cryptoKeyMap.containsKey('Crypto_Key')){
	        Blob cryptoKey = EncodingUtil.convertFromHex(cryptoKeyMap.get('Crypto_Key'));
	        ac.accessToken = encryptWithAES256(ac.accessToken, cryptoKey);
            If (String.isNotBlank(ac.refreshToken)) {
                ac.refreshToken = encryptWithAES256(ac.refreshToken, cryptoKey);
            }
	        //ac.TokenId = encryptWithAES256(ac.TokenId, cryptoKey);
	        //ac.TokenSecret = encryptWithAES256(ac.TokenSecret, cryptoKey);
        }
        return ac;
    }

    // Added a new method as BWP_Processor_Config__c directly being referenced in most places -- This method can be called from Processor extenions
    @namespaceAccessible
    public static BWP_Processor_Config__c encryptSecrets(BWP_Processor_Config__c pc) {
        if(cryptoKeyMap.containsKey('Crypto_Key')){
	        Blob cryptoKey = EncodingUtil.convertFromHex(cryptoKeyMap.get('Crypto_Key'));
	        pc.Access_Token__c = encryptWithAES256(pc.Access_Token__c, cryptoKey);
            If (String.isNotBlank(pc.Refresh_Token__c)) {
                pc.Refresh_Token__c = encryptWithAES256(pc.Refresh_Token__c, cryptoKey);
            }
        }
        return pc;
    }

    private static String encryptWithAES256(String secret, Blob key){
        Blob encryptedSecret = Crypto.encryptWithManagedIV('AES256', key, Blob.valueOf(secret));
	    return EncodingUtil.convertToHex(encryptedSecret);
    }
    
    @namespaceAccessible
    public static BreadwinnerUtil.AppConfig decryptSecrets(BreadwinnerUtil.AppConfig ac) {
        BreadwinnerUtil.AppConfig appC = ac;
        if(appC.isAlreadyDecrypted != NULL && appC.isAlreadyDecrypted){
        	return appC;
        }

        String cryptoKeyHex = cryptoKeyMap.containsKey('Crypto_Key') ? cryptoKeyMap.get('Crypto_Key'):'';
        String cryptoKeyLegacyHex = cryptoKeyMap.containsKey('Crypto_Key_Legacy') ? cryptoKeyMap.get('Crypto_Key_Legacy'):'';
        
        Blob cryptoKey;
        String decryptedCK = '';
        try{
	        cryptoKey = EncodingUtil.convertFromHex(cryptoKeyHex);
	        appC.accessToken = decryptAES256(ac.accessToken,cryptoKey);
	        appC.isEncryptionRotationRequired = FALSE;
	        
	    }
        catch(SecurityException se){
        	try{
		        cryptoKey = EncodingUtil.convertFromHex(cryptoKeyLegacyHex);
		        appC.accessToken = decryptAES256(ac.accessToken,cryptoKey);
		    	appC.isEncryptionRotationRequired = TRUE;
		    }
	        catch(Exception e){
        		System.debug(e.getTypeName() +':::'+ e.getMessage() +':::'+e.getCause());
	        	return null;
	        }
        }
        catch(Exception e){
        	System.debug(e.getTypeName() +':::'+ e.getMessage() +':::'+e.getCause());
        	return null;
        }
        If (String.isNotBlank(ac.refreshToken)) {
            appC.refreshToken = decryptAES256(ac.refreshToken,cryptoKey);
        }
        //appC.TokenId = decryptAES256(ac.TokenId,cryptoKey);
        //appC.TokenSecret = decryptAES256(ac.TokenSecret,cryptoKey);
        appC.isAlreadyDecrypted = TRUE;

        return appC;
    }
    
	
    @testVisible
    private static String decryptAES256(String encryptedSecret, Blob key){
    	Blob decryptedSecret = Crypto.decryptWithManagedIV('AES256', key, EncodingUtil.convertFromHex(encryptedSecret));
	    return decryptedSecret.toString();
    }

    // This method can be called from monitoring job - once a day or a week
    public static void verifyAndRotateEncryption(BWP_Processor_Config__c pConf){
    	BreadwinnerUtil.AppConfig ac = BreadwinnerUtil.getProcessorConfigWrapper(pConf);
    	BreadwinnerUtil.AppConfig decryptedAppC = decryptSecrets(ac);
    	if(decryptedAppC!=NULL && decryptedAppC.isEncryptionRotationRequired){
    		BreadwinnerUtil.AppConfig encryptedAppC = encryptSecrets(decryptedAppC);
			BWP_Processor_Config__c bwpc = new BWP_Processor_Config__c(Id=pConf.Id);
			bwpc.Access_Token__c = encryptedAppC.accessToken;
    		bwpc.Refresh_Token__c = encryptedAppC.refreshToken;
            
            BreadwinnerUtil.isBreadwinnerTransaction = true;
            SecurityUtil.dmlUpdate(bwpc);
            if(!(System.isFuture() || System.isBatch() || Test.isRunningTest())){
                APICallHandler.userInteractionLogPush(false, 'Crypto Rotation', 'INFO' , 'Processor Config: '+pConf.Name+' - encrtyption was successfully rotated with the new Crypto Key');
            }
    	}
    }

}