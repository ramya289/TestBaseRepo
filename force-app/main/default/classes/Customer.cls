public class Customer {

    // Response returned from Stripe when fetching historical customers or adding customer to the processor
    // This is also used to deserialize the incoming JSON request when creating the customer
    public class StripeCustomer {
        public String id;
        public String stripe_object;
        public String name;
        public String email;
        public String phone;
        public String description;
        public Boolean delinquent;
        public Integer balance;
        public Integer created;
        public String stripe_currency;
        public String invoice_prefix;
        public Boolean livemode;
        public Address address;
        public Shipping shipping;
        public String default_source;
        public Sources sources;
        public String source;
        public Tax_info tax_info;
        public TaxIds tax_ids;
        public String tax_exempt;
        public List<String> preferred_locales;
        public Id accountId;
    }

    public class Source {
        //Card fields
        public String id;
        public String stripe_object;
        public String name;
        public String address_city;
        public String address_country;
        public String address_line1;
        public String address_line2;
        public String address_state;
        public String address_zip;
        public Integer amount;
        public String brand;
        public String country;
        public String customer;
        public String exp_month;
        public String exp_year;
        public String cardNumber;
        public String fingerprint;
        public String funding;
        public String last4;
        public String cvc;
        //Card post only fields
        public String account_number; //Integer String
        public String payment_method;
        
        //ACH
        public ACH_credit_transfer ach_credit_transfer;
        public String status;
        //Paid card
        public Card card;
        public String client_secret;
        public Long created;
        public String stripe_currency;
        public String flow;
        public Boolean livemode;
        public String statement_descriptor;
        public String stripe_type;
        public String usage;
        //bank
        public String account_holder_name;
        public String account_holder_type;
        public String bank_name;
        public String routing_number;
        
    }
    
    public class Sources {
        public List<Source> data;
        public Integer total_count {get;set;}
    }

    public class ACH_credit_transfer {
        public String account_number; // integer
        public String routing_number;
        public String swift_code;
        public String bank_name;
        public String fingerprint;
        public String refund_account_holder_name;
        public String refund_account_holder_type;
        public String refund_account_number; //Integer
        public Integer refund_routing_number;
        
    }

    public class Card {
        public String brand;
        public String country;
        public Integer exp_month;
        public Integer exp_year;
        public String fingerprint;
        public String funding;
        public Integer last4;
        public String name;
        
    }

    public class TaxIds {
        public List<Tax_info> data;
    }
    
    public class Tax_info {
        public String tax_id;
        public String stripe_type;
        public String id;
        public String stripe_object;
        public String country;
        public String value;
        public String customer;
    }

    public class Shipping {
        public Address address;
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
    public class verifyBankAccount {
        public String customerId;
        public String bankId;
        public Decimal firstDeposit;
        public Decimal secondDeposit;
    }
    // End Stripe customer response

    // Response returned from Braintree when fetching historical customers or adding customer to the processor
    // This is also used to deserialize the incoming JSON request when creating the customer
    public class BraintreeCustomer {
        public String id;
        public String legacyId;
        public String company;
        public String firstName;
        public String lastName;
        public String phoneNumber;
        public String email;
        public Datetime createdAt;
        public PaymentMethodNode defaultPaymentMethod;
        public PaymentMethod paymentMethods;
        public List<PaymentMethodDetails> paymentMethodDetails;
        public Id accountId;
    }

    public class PaymentMethod {
        public List<PaymentMethodEdges> edges;
    }

    public class PaymentMethodEdges {
        public PaymentMethodNode node;
    }

    public class PaymentMethodNode {
        public String id;
        public Datetime createdAt;
        public PaymentMethodDetails details;
    }

    public class PaymentMethodDetails {
        public String cardNumber;
        public String brandCode;
        public String last4;
        public String expirationMonth;
        public String expirationYear;
        public String cardholderName;
        public String uniqueNumberIdentifier;
        // US Bank Account Variables
        public String accountNumber;
        public String routingNumber;
        public String accountType; // CHECKING, SAVINGS
        public String achMandate;
        public BusinessOwner businessOwner;
        public IndividualOwner individualOwner;
        public String typename;
        public String verified; 
        public String bankName;
        public String accountholderName;
    }
    public class BusinessOwner{
        public String businessName; 
    }
    public class IndividualOwner{
        public String firstName; 
        public String lastName; 
    }
    // End Braintree customer response

    // Response returned from Square when fetching historical customers
    public class SquareCustomer {
        public String id;
        public SquareAddress address;
        public String company_name;
        public String created_at;
        public String email_address;
        public String family_name;
        public String given_name;
        public String phone_number;
        public String note;
        public Id accountId;
        //Cards
        public List<SquareCard> cards;
    }
    public class SquareAddress{
        public String address_line_1;
        public String address_line_2;
        public String locality; //city
        public String administrative_district_level_1; //state
        public String postal_code;
        public String country;
    }
    public class SquareCard{
        public String id;
        public SquareAddress billing_address;
        public String card_brand;
        public String cardholder_name;
        public Integer exp_month;
        public Integer exp_year;
        public String fingerprint;
        public String last_4;
        public String card_nonce;
    }
    // End Square response
}