import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class BoatSearch extends NavigationMixin(LightningElement)
{
    // handles loading event
    isLoading = false;
    
    handleLoading()
    { 
        isLoading = true;
    }
    
    handleDoneLoading()
    { 
        isLoading = false;
    }

    searchBoats(event)
    {
        // this custom event comes from the form
        boatTypeId = event.detail.boatTypeId;
        this.template.querySelector('c-boat-search-results').searchBoats(boatTypeId);
        this.handleDoneLoading();
    }
    
    createNewBoat()
    {
        this[NavigationMixin.Navigate](
        {
            type: 'standard__objectPage',
            attributes:
            {
                objectApiName: 'Boat__c',
                actionName: 'new'
            }
        });
    }
}
  