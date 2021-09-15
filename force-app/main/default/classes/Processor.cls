public abstract with sharing class Processor {

    public virtual ProcessorUtil.ResponseObject createCustomer(String requestJSON){
        throw new BreadwinnerUtil.UnsupportedProcessorException('Error creating customer: This action is not supported.');
    }

    public virtual ProcessorUtil.ResponseObject updateCustomer(String requestJSON){
        throw new BreadwinnerUtil.UnsupportedProcessorException('Error updating customer: This action is not supported.');
    }

    public virtual ProcessorUtil.ResponseObject createBankToken(String requestJSON){
        throw new BreadwinnerUtil.UnsupportedProcessorException('Error creating bank token: This action is not supported.');
    }

    public virtual ProcessorUtil.ResponseObject createCardToken(String requestJSON){
        throw new BreadwinnerUtil.UnsupportedProcessorException('Error creating bank token: This action is not supported.');
    }

    public virtual ProcessorUtil.ResponseObject chargeProcessor(String requestJSON, String timeout){
        throw new BreadwinnerUtil.UnsupportedProcessorException('Error charging processor: This action is not supported.');
    }

    public virtual ProcessorUtil.ResponseObject fetchCustomers(String requestJSON) {
        throw new BreadwinnerUtil.UnsupportedProcessorException('Error fetching customers: This action is not supported.');
    }

    public virtual ProcessorUtil.ResponseObject fetchPayments(String endpoint) {
        throw new BreadwinnerUtil.UnsupportedProcessorException('Error fetching customers: This action is not supported.');
    }
    
    public virtual ProcessorUtil.ResponseObject verifyBankAccount(String requestJSON) {
        throw new BreadwinnerUtil.UnsupportedProcessorException('Error Verifying Bank Account: This action is not supported.');
    }
}