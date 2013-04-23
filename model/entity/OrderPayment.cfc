/*

    Slatwall - An Open Source eCommerce Platform
    Copyright (C) 2011 ten24, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

*/
component entityname="SlatwallOrderPayment" table="SlatwallOrderPayment" persistent="true" output="false" accessors="true" extends="HibachiEntity" cacheuse="transactional" hb_serviceName="orderService" hb_permission="order.orderPayments" hb_processContexts="processTransaction" {
	
	// Persistent Properties
	property name="orderPaymentID" ormtype="string" length="32" fieldtype="id" generator="uuid" unsavedvalue="" default="";
	property name="amount" ormtype="big_decimal";
	property name="currencyCode" ormtype="string" length="3";
	property name="bankRoutingNumberEncrypted" ormType="string";
	property name="bankAccountNumberEncrypted" ormType="string";
	property name="checkNumberEncrypted" ormType="string";
	property name="creditCardNumberEncrypted" ormType="string";
	property name="creditCardLastFour" ormType="string";
	property name="creditCardType" ormType="string";
	property name="expirationMonth" ormType="string" hb_formfieldType="select";
	property name="expirationYear" ormType="string" hb_formfieldType="select";
	property name="giftCardNumberEncrypted" ormType="string";
	property name="nameOnCreditCard" ormType="string";
	property name="providerToken" ormType="string";
	
	// Related Object Properties (many-to-one)
	property name="accountPaymentMethod" cfc="AccountPaymentMethod" fieldtype="many-to-one" fkcolumn="accountPaymentMethodID";
	property name="billingAddress" cfc="Address" fieldtype="many-to-one" fkcolumn="billingAddressID" cascade="all";
	property name="order" cfc="Order" fieldtype="many-to-one" fkcolumn="orderID";
	property name="orderPaymentType" cfc="Type" fieldtype="many-to-one" fkcolumn="orderPaymentTypeID" hb_optionsSmartListData="f:parentType.systemCode=orderPaymentType";
	property name="paymentMethod" cfc="PaymentMethod" fieldtype="many-to-one" fkcolumn="paymentMethodID";
	property name="referencedOrderPayment" cfc="OrderPayment" fieldtype="many-to-one" fkcolumn="referencedOrderPaymentID";
	property name="termPaymentAccount" cfc="Account" fieldtype="many-to-one" fkcolumn="termPaymentAccountID";
	
	// Related Object Properties (one-to-many)			
	property name="attributeValues" singularname="attributeValue" cfc="AttributeValue" type="array" fieldtype="one-to-many" fkcolumn="orderPaymentID" cascade="all-delete-orphan" inverse="true";
	property name="paymentTransactions" singularname="paymentTransaction" cfc="PaymentTransaction" type="array" fieldtype="one-to-many" fkcolumn="orderPaymentID" cascade="all" inverse="true" orderby="createdDateTime DESC" ;
	property name="referencingOrderPayments" singularname="referencingOrderPayment" cfc="OrderPayment" fieldType="one-to-many" fkcolumn="referencedOrderPaymentID" cascade="all" inverse="true";

	// Related Object Properties (many-to-many - owner)

	// Related Object Properties (many-to-many - inverse)
	
	// Remote properties
	property name="remoteID" ormtype="string";
	
	// Audit properties
	property name="createdDateTime" hb_populateEnabled="false" ormtype="timestamp";
	property name="createdByAccount" hb_populateEnabled="false" cfc="Account" fieldtype="many-to-one" fkcolumn="createdByAccountID";
	property name="modifiedDateTime" hb_populateEnabled="false" ormtype="timestamp";
	property name="modifiedByAccount" hb_populateEnabled="false" cfc="Account" fieldtype="many-to-one" fkcolumn="modifiedByAccountID";
	
	// Non-Persistent Properties
	property name="amountAuthorized" type="numeric" hb_formatType="currency" persistent="false";
	property name="amountCredited" type="numeric" hb_formatType="currency" persistent="false";
	property name="amountReceived" type="numeric" hb_formatType="currency" persistent="false";
	property name="amountUnauthorized" persistent="false" hb_formatType="currency";	
	property name="amountUncredited" persistent="false" hb_formatType="currency";
	property name="amountUncaptured" persistent="false" hb_formatType="currency";
	property name="amountUnreceived" persistent="false" hb_formatType="currency";
	property name="bankRoutingNumber" persistent="false";
	property name="bankAccountNumber" persistent="false";
	property name="checkNumber" persistent="false";
	property name="creditCardNumber" persistent="false";
	property name="expirationDate" persistent="false";
	property name="experationMonthOptions" persistent="false";
	property name="expirationYearOptions" persistent="false";
	property name="giftCardNumber" persistent="false";
	property name="paymentMethodType" persistent="false";
	property name="paymentMethodOptions" persistent="false";
	property name="orderStatusCode" persistent="false";
	property name="securityCode" persistent="false";
	property name="peerOrderPaymentNullAmountExistsFlag" persistent="false";
	property name="orderAmountNeeded" persistent="false";
	
	public string function getMostRecentChargeProviderTransactionID() {
		for(var i=1; i<=arrayLen(getPaymentTransactions()); i++) {
			if(!isNull(getPaymentTransactions()[i].getAmountReceived()) && getPaymentTransactions()[i].getAmountReceived() > 0 && !isNull(getPaymentTransactions()[i].getProviderTransactionID()) && len(getPaymentTransactions()[i].getProviderTransactionID())) {
				return getPaymentTransactions()[i].getProviderTransactionID();
			}
		}
		// Check referenced payment, and might have a charge.  This works recursivly
		if(!isNull(getReferencedOrderPayment())) {
			return getReferencedOrderPayment().getMostRecentChargeProviderTransactionID();
		}
		return "";
	}
	
	public void function copyFromAccountPaymentMethod(required any accountPaymentMethod) {
		
		// Connect this to the original account payment method
		setAccountPaymentMethod( arguments.accountPaymentMethod );
		
		// Make sure the payment method matches
		setPaymentMethod( arguments.accountPaymentMethod.getPaymentMethod() );
		
		// Credit Card
		if(listFindNoCase("creditCard", arguments.accountPaymentMethod.getPaymentMethod().getPaymentMethodType())) {
			setNameOnCreditCard( arguments.accountPaymentMethod.getNameOnCreditCard() );
			setCreditCardNumber( arguments.accountPaymentMethod.getCreditCardNumber() );
			setExpirationMonth( arguments.accountPaymentMethod.getExpirationMonth() );
			setExpirationYear( arguments.accountPaymentMethod.getExpirationYear() );
		}
		
		// Gift Card
		if(listFindNoCase("giftCard", arguments.accountPaymentMethod.getPaymentMethod().getPaymentMethodType())) {
			setGiftCardNumber( arguments.accountPaymentMethod.getGiftCardNumber() );
		}
		
		// Credit Card & Gift Card
		if(listFindNoCase("creditCard,giftCard", arguments.accountPaymentMethod.getPaymentMethod().getPaymentMethodType())) {
			setProviderToken( arguments.accountPaymentMethod.getProviderToken() );
		}
		
		// Credit Card & Term Payment
		if(listFindNoCase("creditCard,termPayment", arguments.accountPaymentMethod.getPaymentMethod().getPaymentMethodType())) {
			setBillingAddress( arguments.accountPaymentMethod.getBillingAddress().copyAddress( true ) );
		}
		
	}	
	
	// ============ START: Non-Persistent Property Methods =================
	
	public numeric function getAmountReceived() {
		var amountReceived = 0;
		
		// We only show 'received' for charged payments
		if( getOrderPaymentType().getSystemCode() == "optCharge" ) {
			
			for(var i=1; i<=arrayLen(getPaymentTransactions()); i++) {
				amountReceived = precisionEvaluate(amountReceived + getPaymentTransactions()[i].getAmountReceived());
			}
			
		}
				
		return amountReceived;
	}
	
	public numeric function getAmountCredited() {
		var amountCredited = 0;
		
		// We only show 'credited' for credited payments
		if( getOrderPaymentType().getSystemCode() == "optCredit" ) {
			
			for(var i=1; i<=arrayLen(getPaymentTransactions()); i++) {
				amountCredited = precisionEvaluate(amountCredited + getPaymentTransactions()[i].getAmountCredited());
			}
			
		}
			
		return amountCredited;
	}
	

	public numeric function getAmountAuthorized() {
		var amountAuthorized = 0;
			
		for(var i=1; i<=arrayLen(getPaymentTransactions()); i++) {
			amountAuthorized = precisionEvaluate(amountAuthorized + getPaymentTransactions()[i].getAmountAuthorized());
		}
			
		return amountAuthorized;
	}
	
	public numeric function getAmountUnauthorized() {
		var unauthroized = 0;
		
		if ( getOrderPaymentType().getSystemCode() == "optCharge" ) {
			unauthroized = precisionEvaluate(getAmount() - getAmountReceived() - getAmountAuthorized());
		}
		
		return unauthroized;
	}
	
	public numeric function getAmountUncaptured() {
		var uncaptured = 0;
		
		if ( getOrderPaymentType().getSystemCode() == "optCharge" ) {
			uncaptured = precisionEvaluate(getAmountAuthorized() - getAmountReceived());
		}
		
		return uncaptured;
	}
	
	public numeric function getAmountUnreceived() {
		var unreceived = 0;
		
		if ( getOrderPaymentType().getSystemCode() == "optCharge" ) {
			unreceived = precisionEvaluate(getAmount() - getAmountReceived());
		}
		
		return unreceived;
	}
	
	public numeric function getAmountUncredited() {
		var uncredited = 0;
		
		if ( getOrderPaymentType().getSystemCode() == "optCredit" ) {
			uncredited = precisionEvaluate(getAmount() - getAmountCredited());
		}
		
		return uncredited;
	}
	
	public void function setCreditCardNumber(required string creditCardNumber) {
		if(len(arguments.creditCardNumber)) {
			variables.creditCardNumber = arguments.creditCardNumber;
			setCreditCardLastFour(Right(arguments.creditCardNumber, 4));
			setCreditCardType( getService("paymentService").getCreditCardTypeFromNumber(arguments.creditCardNumber) );
			if(getCreditCardType() != "Invalid" && !isNull(getPaymentMethod()) && getPaymentMethod().setting("paymentMethodStoreCreditCardNumberWithOrder") == 1) {
				setCreditCardNumberEncrypted(encryptValue(arguments.creditCardNumber));
			}
		} else {
			setCreditCardType(javaCast("null", ""));
			setCreditCardNumberEncrypted(javaCast("null", ""));
		}
	}
	
	public string function getCreditCardNumber() {
		if(!structKeyExists(variables,"creditCardNumber")) {
			if(nullReplace(getCreditCardNumberEncrypted(), "") NEQ "") {
				variables.creditCardNumber = decryptValue(getCreditCardNumberEncrypted());
			} else {	
				variables.creditCardNumber = "";
			}
		}
		return variables.creditCardNumber;
	}
	
	public string function getExpirationDate() {
		if(!structKeyExists(variables,"expirationDate")) {
			variables.expirationDate = nullReplace(getExpirationMonth(),"") & "/" & nullReplace(getExpirationYear(), "");
		}
		return variables.expirationDate;
	}
	
	public array function getExpirationMonthOptions() {
		return [
			'01',
			'02',
			'03',
			'04',
			'05',
			'06',
			'07',
			'08',
			'09',
			'10',
			'11',
			'12'
		];
	}
	
	public array function getExpirationYearOptions() {
		var yearOptions = [];
		var currentYear = year(now());
		for(var i = 0; i < 20; i++) {
			var thisYear = currentYear + i;
			arrayAppend(yearOptions,{name=thisYear, value=right(thisYear,2)});
		}
		return yearOptions;
	}
	
	public string function getPaymentMethodType() {
		if(!isNull(getPaymentMethod())) {
			return getPaymentMethod().getPaymentMethodType();
		}
		return javaCast("null", "");
	}
	
	public any function getOrderStatusCode() {
		return getOrder().getStatusCode();
	}
	
	public any function getPaymentMethodOptions() {
		if(!structKeyExists(variables, "paymentMethodOptions")) {
			var sl = getService("paymentService").getPaymentMethodSmartList();
			sl.addFilter('activeFlag', 1);
			sl.addSelect('paymentMethodID', 'value');
			sl.addSelect('paymentMethodName', 'name');
			sl.addSelect('paymentMethodType', 'paymentmethodtype');
			
			variables.paymentMethodOptions = sl.getRecords();
		}
		return variables.paymentMethodOptions;
	}
	
	public any function getPeerOrderPaymentNullAmountExistsFlag() {
		if(!structKeyExists(variables, "peerOrderPaymentNullAmountExistsFlag")) {
			variables.peerOrderPaymentNullAmountExistsFlag = getService("orderService").getPeerOrderPaymentNullAmountExistsFlag(orderID=getOrder().getOrderID(), orderPaymentTypeID=getOrderPaymentType().getTypeID(), orderPaymentID=getOrderPaymentID());
		}
		return variables.peerOrderPaymentNullAmountExistsFlag;
	}
	
	// Important this can be a negative number
	public any function getOrderAmountNeeded() {
		
		if(!structKeyExists(variables, "orderAmountNeeded")) {
			
			var total = getOrder().getTotal();
			var paymentTotal = getService("orderService").getOrderPaymentNonNullAmountTotal(orderID=getOrder().getOrderID());
			
			variables.orderAmountNeeded = precisionEvaluate( total - paymentTotal);
		}
		
		return variables.orderAmountNeeded;
	}
	
	// ============  END:  Non-Persistent Property Methods =================
		
	// ============= START: Bidirectional Helper Methods ===================
	
	// Account Payment Method (many-to-one)    
	public void function setAccountPaymentMethod(required any accountPaymentMethod) {    
		variables.accountPaymentMethod = arguments.accountPaymentMethod;    
		if(isNew() or !arguments.accountPaymentMethod.hasOrderPayment( this )) {    
			arrayAppend(arguments.accountPaymentMethod.getOrderPayments(), this);    
		}    
	}    
	public void function removeAccountPaymentMethod(any accountPaymentMethod) {    
		if(!structKeyExists(arguments, "accountPaymentMethod")) {    
			arguments.accountPaymentMethod = variables.accountPaymentMethod;    
		}    
		var index = arrayFind(arguments.accountPaymentMethod.getOrderPayments(), this);    
		if(index > 0) {    
			arrayDeleteAt(arguments.accountPaymentMethod.getOrderPayments(), index);    
		}    
		structDelete(variables, "accountPaymentMethod");    
	}
	
	// Order (many-to-one)
	public void function setOrder(required any order) {
		variables.order = arguments.order;
		if(isNew() or !arguments.order.hasOrderPayment( this )) {
			arrayAppend(arguments.order.getOrderPayments(), this);
		}
	}
	public void function removeOrder(any order) {
		if(!structKeyExists(arguments, "order")) {
			arguments.order = variables.order;
		}
		var index = arrayFind(arguments.order.getOrderPayments(), this);
		if(index > 0) {
			arrayDeleteAt(arguments.order.getOrderPayments(), index);
		}
		structDelete(variables, "order");
	}
	
	// Referenced Order Payment (many-to-one)    
	public void function setReferencedOrderPayment(required any referencedOrderPayment) {    
		variables.referencedOrderPayment = arguments.referencedOrderPayment;    
		if(isNew() or !arguments.referencedOrderPayment.hasReferencingOrderPayment( this )) {    
			arrayAppend(arguments.referencedOrderPayment.getReferencingOrderPayments(), this);    
		}    
	}    
	public void function removeReferencedOrderPayment(any referencedOrderPayment) {    
		if(!structKeyExists(arguments, "referencedOrderPayment")) {    
			arguments.referencedOrderPayment = variables.referencedOrderPayment;    
		}    
		var index = arrayFind(arguments.referencedOrderPayment.getReferencingOrderPayments(), this);    
		if(index > 0) {    
			arrayDeleteAt(arguments.referencedOrderPayment.getReferencingOrderPayments(), index);    
		}    
		structDelete(variables, "referencedOrderPayment");    
	}
	
	// Payment Method (many-to-one)
	public void function setPaymentMethod(required any paymentMethod) {
		variables.paymentMethod = arguments.paymentMethod;
		if(isNew() or !arguments.paymentMethod.hasOrderPayment( this )) {
			arrayAppend(arguments.paymentMethod.getOrderPayments(), this);
		}
	}
	public void function removePaymentMethod(any paymentMethod) {
		if(!structKeyExists(arguments, "paymentMethod")) {
			arguments.paymentMethod = variables.paymentMethod;
		}
		var index = arrayFind(arguments.paymentMethod.getOrderPayments(), this);
		if(index > 0) {
			arrayDeleteAt(arguments.paymentMethod.getOrderPayments(), index);
		}
		structDelete(variables, "paymentMethod");
	}
	
	// Term Payment Account (many-to-one)    
	public void function setTermPaymentAccount(required any termPaymentAccount) {    
		variables.termPaymentAccount = arguments.termPaymentAccount;    
		if(isNew() or !arguments.termPaymentAccount.hasTermAccountOrderPayment( this )) {    
			arrayAppend(arguments.termPaymentAccount.getTermAccountOrderPayments(), this);    
		}    
	}    
	public void function removeTermPaymentAccount(any termPaymentAccount) {    
		if(!structKeyExists(arguments, "termPaymentAccount")) {    
			arguments.termPaymentAccount = variables.termPaymentAccount;    
		}    
		var index = arrayFind(arguments.termPaymentAccount.getTermAccountOrderPayments(), this);    
		if(index > 0) {    
			arrayDeleteAt(arguments.termPaymentAccount.getTermAccountOrderPayments(), index);    
		}    
		structDelete(variables, "termPaymentAccount");    
	}
	
	// AttributeValues (one-to-many)
	public void function addAttributeValue(required any attributeValue) {
		arguments.attributeValue.setOrderPayment( this );
	}
	public void function removeAttributeValue(required any attributeValue) {
		arguments.attributeValue.removeOrderPayment( this );
	}
	
	// Payment Transactions (one-to-many)
	public void function addPaymentTransaction(required any paymentTransaction) {
		arguments.paymentTransaction.setOrderPayment( this );
	}
	public void function removePaymentTransaction(required any paymentTransaction) {
		arguments.paymentTransaction.removeOrderPayment( this );
	}
	
	// Referencing Order Payments (one-to-many)    
	public void function addReferencingOrderPayment(required any referencingOrderPayment) {    
		arguments.referencingOrderPayment.setReferencedOrderPayment( this );    
	}    
	public void function removeReferencingOrderPayment(required any referencingOrderPayment) {    
		arguments.referencingOrderPayment.removeReferencedOrderPayment( this );    
	}
	
	// =============  END:  Bidirectional Helper Methods ===================

	// =============== START: Custom Validation Methods ====================
	
	// ===============  END: Custom Validation Methods =====================
	
	// =============== START: Custom Formatting Methods ====================
	
	// ===============  END: Custom Formatting Methods =====================
	
	// ============== START: Overridden Implicet Getters ===================
	
	public numeric function getAmount() {
		// If an amount has not been explicity set, then we can return another value if needed
		if( !structKeyExists(variables, "amount") ) {
			
			// If there is an order, it has not been placed and there is only 1 order payment with no explicit value set... then we can return the order total.
			if(!isNull(getOrder()) && getOrder().getOrderStatusType().getSystemCode() eq "ostNotPlaced" && !getPeerOrderPaymentNullAmountExistsFlag()) {
				var orderAmountNeeded = getOrderAmountNeeded();
				if(orderAmountNeeded gt 0 && getOrderPaymentType().getSystemCode() eq "optCharge") {
					return orderAmountNeeded;
				} else if (orderAmountNeeded gt 0 && getOrderPaymentType().getSystemCode() eq "optCredit") {
					return orderAmountNeeded * -1;
				}
				return 0;
			}
			
			// If for some reson the above logic did not fire then just set the amount to 0
			variables.amount = 0;
			
		}
		
		return variables.amount;
	}

	public any function getBillingAddress() {
		if( !structKeyExists(variables, "billingAddress") ) {
			return getService("addressService").newAddress();
		}
		return variables.billingAddress;
	}
	
	public any function getOrderPaymentType() {
		if( !structKeyExists(variables, "orderPaymentType") ) {
			variables.orderPaymentType = getService("settingService").getTypeBySystemCode("optCharge");
		}
		return variables.orderPaymentType;
	}
	
	// ==============  END: Overridden Implicet Getters ====================

	// ================== START: Overridden Methods ========================
	
	public any function getSimpleRepresentation() {
		if(this.isNew()) {
			return rbKey('define.new') & ' ' & rbKey('entity.orderPayment');
		}
		
		if(getPaymentMethodType() == "creditCard") {
			return getPaymentMethod().getPaymentMethodName() & " - " & getCreditCardType() & " ***" & getCreditCardLastFour() & ' - ' & getFormattedValue('amount');	
		}
		
		return getPaymentMethod().getPaymentMethodName() & ' - ' & getFormattedValue('amount');
	}
	
	// ==================  END:  Overridden Methods ========================
	
	// =================== START: ORM Event Hooks  =========================
	
	public void function preInsert(){
		super.preInsert();
		
		// Verify Defaults are Set
		getOrderPaymentType();
	}
	
	// ===================  END:  ORM Event Hooks  =========================
}
