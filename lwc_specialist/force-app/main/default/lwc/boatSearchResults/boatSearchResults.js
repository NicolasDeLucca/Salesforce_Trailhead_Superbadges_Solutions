import { LightningElement, wire, api, track } from 'lwc';

import { refreshApex } from '@salesforce/apex';
import updateBoatList from '@salesforce/apex/BoatDataService.updateBoatList';
import getBoats from '@salesforce/apex/BoatDataService.getBoats';
import BOATMC from '@salesforce/messageChannel/BoatMessageChannel__c';

import { MessageContext, publish } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BoatSearchResults extends LightningElement
{
  @api
  selectedBoatId;
  @track
  boats;
  @track
  draftValues = [];

  isLoading = false;
  columns = [
    { label: 'Name', fieldName: 'Name', editable: true },
    { label: 'Length', fieldName: 'Length__c', type: 'number' },
    { label: 'Price', fieldName: 'Price__c', type: 'currency' },
    { label: 'Description', fieldName: 'Description__c' }
  ];
  boatTypeId = '';
  
  @wire(MessageContext)
  messageContext;

  @wire(getBoats, {boatTypeId: '$boatTypeId'})
  wiredBoats(result)
  { 
    this.boats = result;
  }
  
  @api
  searchBoats(boatTypeId)
  { 
    this.isLoading = true;
    this.notifyLoading(this.isLoading);
    this.boatTypeId = boatTypeId;
  }
  
  @api
  async refresh()
  { 
    this.isLoading = true;
    this.notifyLoading(this.isLoading)
    await refreshApex(this.boats);
    this.isLoading = false;
  }
  
  updateSelectedTile(event)
  { 
    this.selectedBoatId = event.detail.boatId;
    this.sendMessageService(this.selectedBoatId);
  }
  
  sendMessageService(boatId)
  { 
    publish(
      this.messageContext, 
      BOATMC, 
      { 
        recordId: boatId 
      }
    );
  }
  
  handleSave(event)
  {
    this.isLoading = true;
    this.notifyLoading(this.isLoading);
    const updatedFields = event.detail.draftValues;

    updateBoatList({data: updatedFields})
    .then(() => 
    {
        const toastEvent = new ShowToastEvent(
        {
          title: SUCCESS_TITLE,
          message: MESSAGE_SHIP_IT,
          variant: SUCCESS_VARIANT
        });

        this.dispatchEvent(toastEvent);
        this.draftValues = [];
        this.refresh();
    })
    .catch(error => 
    {
        const toastEvent = new ShowToastEvent(
        {
          title: ERROR_TITLE,
          message: error.body.message,
          variant: ERROR_VARIANT
        });

        this.dispatchEvent(toastEvent);
    }).finally(() => {});
  }

  notifyLoading(isLoading)
  { 
    eventType = isLoading ? 'loading' : 'doneloading';
    customEvent = new CustomEvent(eventType);

    this.dispatchEvent(customEvent);
  }

}
