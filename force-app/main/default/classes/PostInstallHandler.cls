public without sharing class PostInstallHandler implements InstallHandler {
    public void onInstall(InstallContext context) {
        if(context.previousVersion() == NULL) {
            //-- Send request to create record in sf_org table
            APICallHandler.asyncCreateSFOrg(context.installerId(),TRUE);
        }
        else{
            //-- Already installed
            if(context.isUpgrade()) APICallHandler.userInteractionLogPush(FALSE, 'upgrade', '', 'Package Upgrade from previous version: ' + context.previousVersion());
            else if (context.isPush()) APICallHandler.userInteractionLogPush(FALSE, 'push upgrade', '', 'Package Push Upgrade from previous version: ' + context.previousVersion());
            else APICallHandler.userInteractionLogPush(FALSE, 'install', '', 'Package Installation');
        }
    }
}