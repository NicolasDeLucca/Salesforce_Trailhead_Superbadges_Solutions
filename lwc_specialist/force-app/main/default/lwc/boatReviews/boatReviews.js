import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAllReviews from '@salesforce/apex/BoatDataService.getAllReviews';

export default class BoatReviews extends NavigationMixin(LightningElement)
{
  boatId;
  boatReviews=[];
  isLoading;
  error;
  
  @api
  get recordId()
  { 
    return this.boatId;
  }

  set recordId(value)
  {
    this.setAttribute('boatId', value);
    this.boatId = value;
    this.getReviews(); // refresh the reviews associated with boatId
  }
  
  @api
  get reviewsToShow()
  { 
    return this.boatReviews != null && this.boatReviews.length > 0;
  }
  
  @api
  refresh()
  { 
    this.getReviews(); // force a refresh of the reviews
  }
  
  getReviews()
  { 
    if (this.boatId == undefined || this.boatId == null)
        return;

    this.isLoading = true;
    getAllReviews({boatId: this.boatId}).
    then(result => 
    {
        this.boatReviews = result;
    }).
    catch(error => 
    {
        this.error = error;
    }).
    finally(() => 
    {
        this.isLoading = false;
    });
  }
  
  // navigate to a given record on click
  navigateToRecord(event)
  {  
    event.preventDefault();
    event.stopPropagation(); // stop the event from bubbling the DOM Hierarchy

    this[NavigationMixin.Navigate](
    {
      type: 'standard__recordPage',
      attributes:
      {
        recordId: event.target.dataset.recordId,
        objectApiName: 'User',
        actionName: 'view'
      }
    });
  }

}
