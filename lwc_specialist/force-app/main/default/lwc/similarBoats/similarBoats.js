import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'

import getSimilarBoats from '@salesforce/apex/BoatDataService.getSimilarBoats';

export default class SimilarBoats extends NavigationMixin(LightningElement)
{
  @api
  similarBy;

  relatedBoats;
  boatId;
  error;
  
  set recordId(value)
  {
    this.setAttribute('boatId', this.boatId);
    this.boatId = value;   
  }  

  @api
  get recordId()
  {
    return this.boatId;
  }

  get getTitle()
  {
    return 'Similar boats by ' + this.similarBy;
  }

  get noBoats()
  {
    return !(this.relatedBoats && this.relatedBoats.length > 0);
  }
  
  // Populates the relatedBoats list
  @wire(getSimilarBoats, {boatId: '$boatId', similarBy: '$similarBy'})
  similarBoats({ error, data })
  { 
    if (data)
    {
        this.relatedBoats = data;
        this.error = undefined;
    }
    else if (error)
    {
        this.error = error;
    }
  }
  
  openBoatDetailPage(event)
  { 
    this[NavigationMixin.Navigate](
    {
      type:'standard__recordPage',
      attributes:
      {
        recordId: event.detail.boatId,
        objectApiName: 'Boat__c',
        actionName: 'view'
      }
    });
  }

}
