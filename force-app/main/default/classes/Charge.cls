public class Charge {

    // Responses returned from Braintree when fetching historical payments
    public class BraintreeCharge {
        public Amount amount;
        public String id;
        public String legacyId;
        public Datetime createdAt;
        public String merchantAccountId;
        public String status;
        public Customer customer;
        public PaymentMethod paymentMethod;
        public TransactionTaxInput transactionTaxInput;
    }
    public class Customer {
        public String id;
    }

    public class Amount {
        public String value;
        public String currencyISOCode;
    }
    public class PaymentMethod {
        public String id;
    }
    public class TransactionTaxInput {
        public Amount taxAmount;
        public Boolean taxExempt;
    }
    // End Braintree responses

    // Response returned from Stripe when fetching historical payments or charging the processor
    // This is also used to deserialize the incoming JSON request when charging the processor
    public class StripeCharge {
        public String id;
        public String stripe_object;
        public Decimal amount;
        public Integer application_fee_amount;
        public Integer amount_refunded;
        public BillingAddress billing_details;
        public Boolean captured;
        public Long created;
        public String stripe_currency;
        public String customer; // Stripe customer Id
        public String description;
        public Boolean livemode;
        public Boolean paid;
        public String payment_intent;
        public String receipt_email;
        public String receipt_number;
        public String receipt_url;
        public String status;
        public Datetime paymentDate;
        public String payment_method;
        public Customer.Source source;
        //these are not part of the response returned from Stripe but are needed in the deserialization process
        public String paymentMethod;  // Processor_Id__c of the selected stored payment
        public String paymentMethodType; // Type__c of the selected stored payment (card, ACHCreditTransfer, or BankTransfer)
    
        //POST variables
        public Boolean capture;
    }
        
    public class BillingAddress {
        public Address address;
        public String email;
        public String name;
        public String phone;
    }
    
    public class Address {
        public String line1;
        public String line2;
        public String city;
        public String state;
        public String country;
        public String postal_code;
    }
    // End Stripe response

    // Response returned from Square when fetching historical payments
    public class SquareCharge {
        public string id;
        public Money amount_money;
        public Money app_fee_money;
        public Customer.SquareAddress billing_address;
       	public CardDetails card_details;
        public String created_at;
        public String customer_id;
        public String source_id;
        public String idempotency_key;
        public String employee_id;
        public String employee_name;
        public String location_id;
        public String note;
        public String order_id;
        public List<processingFee> processing_fee;
        public String receipt_number;
        public String receipt_url;
        public String reference_id;
        public Money refunded_money;
        public String status;
    }

    public class Money {
        public Decimal amount;
        public String square_currency;
    }
    public class CardDetails {
        public String status;
        public Customer.SquareCard card;
    }
    public class processingFee{
        public Money amount_money;
    }
    //End Square Response
    
    // Response returned from PayPal when fetching historical payments
    public class PayPalPayout{
        public String recipient_type;
        public paypalAmount amount;
        public String note;
        public String receiver;
        public String sender_item_id;
        public String recipient_wallet; 
        Public ReceiptName recipient_name;
    }
    public class ReceiptName{
        Public String prefix;
        Public String given_name;
        Public String surname;  
        Public String middle_name;
        Public String full_name;
        Public String alternate_full_name;
        
    }
    public class PayPalAmount{
        public String paypal_currency;
        public String value;
    }
    public class PayPalPayouts {
        public SenderBatchHeader sender_batch_header;
        public List<PayPalPayout> items;
    }
    public class PayPalPayoutItems{
        public BatchHeader batch_header;
        public List<Item> items;
    }
   
    public class Item {
		public String payout_item_id;
		public String transaction_status;
		public PayPalAmount payout_item_fee;
		public String payout_batch_id;
		public PayPalPayout payout_item;
	}
  
    public class BatchHeader{
        public String payout_batch_id;
        public String batch_status;     
        public String time_created;
        public String funding_source;  
        public PayPalAmount amount;
        public SenderBatchHeader sender_batch_header;
    }
    public class SenderBatchHeader{
        public String sender_batch_id;
        public String email_subject;
        public String email_message;
    }
    public class PayPalTransactions{
        public List<TrasactionDetails> transaction_details;
       	public String account_number;
        public Datetime start_date;
        public Datetime end_date;
        public String last_refreshed_datetime;
        public integer page;
        public integer total_items;
        public integer total_pages;
    }
    
    public class TrasactionDetails{
        public TrasactionInfo transaction_info;
        public PayerInfo payer_info;
        public ShippingAddress shipping_info;
       
    }
    
    public class TrasactionInfo{
        public String paypal_account_id;
        public String transaction_id;
        public String paypal_reference_id ;
        public String transaction_event_code;
        public String transaction_initiation_date;
        public String transaction_updated_date;
       	public TrasactionAmount transaction_amount;
        public FeeAmount fee_amount;
        public InsuranceAmount insurance_amount;
        public ShippingAmount shipping_amount;
        public ShippingDiscountAmount shipping_discount_amount;
        public EndingBalance ending_balance;
        public AvailableBalance available_balance;
        public String transaction_status;
        public String transaction_subject; 
        public String transaction_note;
        public String invoice_id; 
        public String custom_field; 
    }
     public class FeeAmount{
        public String currency_code;
        public Decimal value;
    }
     public class TrasactionAmount{
        public String currency_code;
        public Decimal value;
    }
     public class InsuranceAmount{
        public String currency_code;
        public String value;
    }
     public class ShippingAmount{
        public String currency_code;
        public String value;
    }
     public class ShippingDiscountAmount{
        public String currency_code;
        public String value;
    }
    
     public class EndingBalance{
        public String currency_code;
        public String value;
    }
     public class AvailableBalance{
        public String currency_code;
        public String value;
    }
    public class PayerInfo{
        public String account_id;
        public String email_address;
        public String address_status;
        public String payer_status;
        public String country_code;
        public PayerName payer_name;
    }
    public class PayerName{
        public String given_name;
        public String surname;
        public String alternate_full_name;
        
    }
    public class ShippingAddress{
        public String name;
        public String line1;
        public String line2;
        public String city;
        public String state;
        public String country_code;
        public String postal_code;
    }
  	//End PayPal Response
}