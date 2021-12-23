// Start Stripe Create Card 
function stripeCreateCardForm(publishableKey){
    stripe = Stripe(publishableKey); 
    elements = stripe.elements();       
    var style = {       
        base: {     
            color: '#32325d',       
            lineHeight: '18px',     
            fontFamily: '"Helvetica Neue", Helvetica, sans-serif',      
            fontSmoothing: 'antialiased',       
            fontSize: '16px',       
            '::placeholder': {      
                color: '#aab7c4'        
            }       
        },      
        invalid: {      
            color: '#fa755a',       
            iconColor: '#fa755a'        
        }       
    };      
    
    card = elements.create('card', {style: style});      
    card.mount('#card-element');     
    card.addEventListener('change', function(event) {       
        var displayCardError = document.getElementById('card-errors');      
        if (event.error) {  
            displayCardError.textContent = event.error.message;       
        } else {       
            displayCardError.textContent = '';     
        }      
    });         
}
function stripeValidateCard(){
    var card_name = j$("[id$=cardHolderName]").val();
    var addressline1 = j$("[id$=addressline1]").val();
    var addressline2 = j$("[id$=addressline2]").val();
    var city = j$("[id$=city]").val();
    var state = j$("[id$=state]").val();
    var country = j$("[id$=country]").val();
    stripe.createToken(card, {name: card_name, address_line1: addressline1, address_line2: addressline2, address_city: city, address_state: state, address_country: country}).then(function(result) { 
        if(result.error) {
            var errorElement = document.getElementById('card-errors'); 
            errorElement.textContent = result.error.message; 
        } 
        else { 
            token = JSON.stringify(result.token.id).replace(/^"(.*)"$/, '$1');
            j$("[id$=PMTokenValue]").val(token.toString());
            if(token!=null) processtoken(token, '');
        }
    }); 
}
// End Stripe Create Card 


// Start Square Create Card 
var card_info;
async function squareCreateCardForm(appId, locationId){
    
    if (!window.Square) {
        throw new Error('Square.js failed to load properly');
    }

    const payments = window.Square.payments(appId, locationId);
    try {
        card_info = await initializeCard(payments);
        console.log('card initialization was succesful ::: ');
    } catch (e) {
        console.error('Initializing Card failed', e);
        return;
    }
}

async function generateCardToken(){
    try{
        const token = await tokenize(card_info);
    }catch(e){
        console.log('e ::::: ',e.message);
    }
}

async function initializeCard(payments) {
    const card = await payments.card();
    await card.attach('#card-container'); 
    return card; 
}

// This function tokenizes a payment method.
async function tokenize(paymentMethod) {
    const tokenResult = await paymentMethod.tokenize();
    if (tokenResult.status === 'OK') {
        j$("[id$=PMTokenValue]").val(tokenResult.token);
        var token = j$("[id$=PMTokenValue]").val();
        if(token!=null) processtoken(token, '');
        return tokenResult.token;
    } else {
        let squareErrors = '';
        let count = 0;
        for(let tr of tokenResult.errors){
            squareErrors += ' '+ tr.message + (count++ < tokenResult.errors.length-2 ? ',' : ' and');
        }
        squareErrors = squareErrors.substr(0,squareErrors.length-3);
        return;
    }
}

function uuidv4() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}

function setIdempotencyKey(){
    const idempotency_key = uuidv4();
    j$("[id$=idempotencyKey]").val(idempotency_key);
    var idempotencyKey = j$("[id$=idempotencyKey]").val();
    if(idempotencyKey!=null) processKey();
}

// End Square Create Card 

// Start Braintree Create Card 

function braintreeCreateCardForm(clientToken){
	braintree.dropin.create({
		authorization: clientToken,
		selector: '#dropin-container',
		// preselectVaultedPaymentMethod : false,
		translations: { 
		// payingWith: 'Recently added cards',
			chooseAnotherWayToPay: 'Create another card', // Any other custom translation strings 
		}
	}, async function (err, instance) {
		 var button = await document.querySelector('#submit-button');
		// instance.clearSelectedPaymentMethod();
		button.addEventListener('click', function () {
			instance.requestPaymentMethod(function (err, payload) {
				if(payload.nonce != null && err == null){
					j$("[id$=PMTokenValue]").val(payload.nonce);
					processtoken(payload.nonce, '');
				}
			});
		})
	}); 
}

// End Braintree Create Card 