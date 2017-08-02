/// <reference path='../../../typings/slatwallTypescript.d.ts' />
/// <reference path='../../../typings/tsd.d.ts' />

import * as actions from '../actions/fulfillmentbatchactions';

/**
 * Fulfillment Batch Detail Controller
 */
class SWFulfillmentBatchDetailController  {
    
    public state;
    public fulfillmentBatchId: string;
    
    // @ngInject
    constructor(private $hibachi, private $timeout, private collectionConfigService, private observerService, private utilityService, private $location, private $http, private $window, private typeaheadService, private listingService, private orderFulfillmentService, private rbkeyService){
       
        //setup a state change listener and send over the fulfillmentBatchID
        this.orderFulfillmentService.orderFulfillmentStore.store$.subscribe((stateChanges)=>{
            
            //Handle basic requests
            if ( (stateChanges.action && stateChanges.action.type) && (
                stateChanges.action.type == actions.TOGGLE_EDITCOMMENT || 
                stateChanges.action.type == actions.SAVE_COMMENT_REQUESTED || 
                stateChanges.action.type == actions.DELETE_COMMENT_REQUESTED || 
                stateChanges.action.type == actions.CREATE_FULFILLMENT_REQUESTED || 
                stateChanges.action.type == actions.UPDATE_BATCHDETAIL || 
                stateChanges.action.type == actions.SETUP_BATCHDETAIL || 
                stateChanges.action.type == actions.SETUP_ORDERDELIVERYATTRIBUTES ||
                stateChanges.action.type == actions.TOGGLE_LOADER)){
                //GET the state.
                this.state = stateChanges;
            }

        });

        //Get the attributes to display in the custom section.
        this.userViewingOrderDeliveryAttributes();
        //Dispatch the fulfillmentBatchID and setup the state.
        this.userViewingFulfillmentBatchDetail(this.fulfillmentBatchId);

    }
    
    public userViewingFulfillmentBatchDetail = (batchID) => {
         this.orderFulfillmentService.orderFulfillmentStore.dispatch({
            type: actions.SETUP_BATCHDETAIL,
            payload: {fulfillmentBatchId: batchID }
        });
    }

    public userToggleFulfillmentBatchListing = () => {
         this.orderFulfillmentService.orderFulfillmentStore.dispatch({
            type: actions.TOGGLE_BATCHLISTING,
            payload: {}
        });
    }
    
    //toggle_editcomment for action based
    public userEditingComment = (comment) => {
         this.orderFulfillmentService.orderFulfillmentStore.dispatch({
            type: actions.TOGGLE_EDITCOMMENT,
            payload: {comment: comment}
        });
    }
    
    //requested | failed | succeded
    public userDeletingComment = (comment) => {
        //Only fire the event if the user agrees.
        let warning = this.rbkeyService.getRBKey("entity.comment.delete.confirm");
        if ( window.confirm(`${warning}?`) ) {
            this.orderFulfillmentService.orderFulfillmentStore.dispatch({
                type: actions.DELETE_COMMENT_REQUESTED,
                payload: {comment: comment}
            });
        }
    }

    //Try to delete the fulfillment batch item.
    public deleteFulfillmentBatchItem = () => {
        //Only fire the event if the user agrees.
        let warning = this.rbkeyService.getRBKey("entity.comment.delete.confirm");
        if ( window.confirm(`${warning}?`) ) {
            this.orderFulfillmentService.orderFulfillmentStore.dispatch({
                type: actions.DELETE_FULFILLMENTBATCHITEM_REQUESTED,
                payload: {}
            });
        }
    }
    
    public userSavingComment = (comment, commentText) => {
        this.orderFulfillmentService.orderFulfillmentStore.dispatch({
            type: actions.SAVE_COMMENT_REQUESTED,
            payload: {comment: comment, commentText: commentText}
        });
    }

    public userViewingOrderDeliveryAttributes = () => {
        this.orderFulfillmentService.orderFulfillmentStore.dispatch({
            type: actions.SETUP_ORDERDELIVERYATTRIBUTES,
            payload: {}
        });
    }

    public userCaptureAndFulfill = () => {
        //request the fulfillment process.
        this.state.loading = false;
        this.orderFulfillmentService.orderFulfillmentStore.dispatch({
            type: actions.CREATE_FULFILLMENT_REQUESTED,
            payload: { viewState:this.state }
        });
    }

    public userPrintPickingList = () => {
         this.orderFulfillmentService.orderFulfillmentStore.dispatch({
            type: actions.PRINT_PICKINGLIST_REQUESTED,
            payload: {}
        });
    }

    public userPrintPackingList = () => {
         this.orderFulfillmentService.orderFulfillmentStore.dispatch({
            type: actions.PRINT_PACKINGLIST_REQUESTED,
            payload: {}
        });
    }

    public userEmailCancellation = () => {
         this.orderFulfillmentService.orderFulfillmentStore.dispatch({
            type: "SEND_EMAIL_CANCELLATION_ACTION",
            payload: {}
        });
    }

    public userEmailConfirmation = () => {
         this.orderFulfillmentService.orderFulfillmentStore.dispatch({
            type: "SEND_EMAIL_CONFIRMATION_ACTION",
            payload: {}
        });
    }

    public userEmailOrderStatus = () => {
         this.orderFulfillmentService.orderFulfillmentStore.dispatch({
            type: "SEND_EMAIL_ORDER_STATUS_ACTION",
            payload: {}
        });
    }

    public userBarcodeSearch = () => {
         this.orderFulfillmentService.orderFulfillmentStore.dispatch({
            type: "BAR_CODE_SEARCH_ACTION",
            payload: {}
        });
    }
}

/**
 * This is a view helper class that uses the collection helper class.
 */
class SWFulfillmentBatchDetail implements ng.IDirective{

    public templateUrl; 
    public restrict = "EA"; 
    public scope = {}	
    
    public bindToController = {
        fulfillmentBatchId: "@?"
    }

    public controller=SWFulfillmentBatchDetailController;
    public controllerAs="swFulfillmentBatchDetailController";
     
    public static Factory():ng.IDirectiveFactory{
		var directive:ng.IDirectiveFactory = (
            $hibachi, 
            $timeout, 
            collectionConfigService,
            observerService,
			fulfillmentBatchDetailPartialsPath,
			slatwallPathBuilder
		) => new SWFulfillmentBatchDetail (
            $hibachi, 
            $timeout, 
            collectionConfigService,
            observerService,
			fulfillmentBatchDetailPartialsPath,
			slatwallPathBuilder
		);
		directive.$inject = [
            '$hibachi', 
            '$timeout', 
            'collectionConfigService',
            'observerService',
			'fulfillmentBatchDetailPartialsPath',
			'slatwallPathBuilder'
		];
		return directive;
	}
    // @ngInject
    constructor(private $hibachi, private $timeout, private collectionConfigService, private observerService, private fulfillmentBatchDetailPartialsPath, slatwallPathBuilder){
        this.templateUrl = slatwallPathBuilder.buildPartialsPath(fulfillmentBatchDetailPartialsPath) + "fulfillmentbatchdetail.html";	
    }

    public link:ng.IDirectiveLinkFn = ($scope: ng.IScope, element: ng.IAugmentedJQuery, attrs:ng.IAttributes) =>{  
    }
}

export {
    SWFulfillmentBatchDetailController,
	SWFulfillmentBatchDetail
};